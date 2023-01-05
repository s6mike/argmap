/*global require, module, idea_pp */
const _ = require('underscore'),
	MemoryClipboard = require('./clipboard'),
	LayoutModel = require('./layout/layout-model'),
	observable = require('./util/observable'),
	Utilities = require('./util/mapjs-utilities');

module.exports = function MapModel(selectAllTitles, clipboardProvider, defaultReorderMargin, optional) {
	'use strict';
	let idea,
		isAddLinkMode,
		currentLabelGenerator,
		isInputEnabled = true,
		isEditingEnabled = true,
		revertSelectionForUndo,
		revertActivatedForUndo,
		themeSource = false,
		paused = false,
		activatedNodes = [],
		layoutCalculator,
		currentlySelectedIdeaId;

	// TODO: Apparently `const self = this` is now bad practice, so try removing and updating references if necessary
	// 	Or can just rename self to something else
	const self = this,
		autoThemedIdeaUtils = (optional && optional.autoThemedIdeaUtils) || require('./content/auto-themed-idea-utils'),
		clipboard = clipboardProvider || new MemoryClipboard(),
		reorderMargin = (optional && optional.reorderMargin) || 20,
		layoutModel = (optional && optional.layoutModel) || new LayoutModel({ nodes: {}, connectors: {} }),
		setRootNodePositionsForPrecalculatedLayout = function (contextNode, specificLayout) {
			const rootIdeas = Object.keys(idea.ideas).map(rank => idea.ideas[rank]),
				layout = specificLayout || layoutCalculator(idea, contextNode);
			rootIdeas.forEach(rootIdea => {
				const existingPosition = rootIdea.attr && rootIdea.attr.position,
					rootNodeInLayout = layout.nodes && layout.nodes[rootIdea.id],
					shouldUpdatePosition = rootNodeInLayout && (!existingPosition || existingPosition[0] !== rootNodeInLayout.x || existingPosition[1] !== rootNodeInLayout.y);
				if (shouldUpdatePosition) {
					idea.updateAttr(rootIdea.id, 'position', [rootNodeInLayout.x, rootNodeInLayout.y, 1]);
				}
			});
		},
		addSubIdea = (parentId, ideaTitle, optionalNewId, optionalIdeaAttr) => {
			const themeObj = themeSource && themeSource();
			return autoThemedIdeaUtils.addSubIdea(idea, themeObj, parentId, ideaTitle, optionalNewId, optionalIdeaAttr);
		},
		insertIntermediateMultiple = (inFrontOfIdeaIds, ideaOptions) => {
			const themeObj = themeSource && themeSource();
			return autoThemedIdeaUtils.insertIntermediateMultiple(idea, themeObj, inFrontOfIdeaIds, ideaOptions);
		},
		changeParent = (ideaId, newParentId) => {
			const themeObj = themeSource && themeSource();
			return autoThemedIdeaUtils.changeParent(idea, themeObj, ideaId, newParentId);
		},
		setActiveNodes = function (activated) {
			const wasActivated = _.clone(activatedNodes);
			if (activated.length === 0) {
				activatedNodes = [currentlySelectedIdeaId];
			} else {
				activatedNodes = activated;
			}
			self.dispatchEvent('activatedNodesChanged', _.difference(activatedNodes, wasActivated), _.difference(wasActivated, activatedNodes));
		},
		applyLabels = function (newLayout) {
			const labelMap = currentLabelGenerator && currentLabelGenerator(idea);
			if (!labelMap) {
				return;
			}
			_.each(newLayout.nodes, function (node, id) {
				if (labelMap[id] || labelMap[id] === 0) {
					node.label = labelMap[id];
				}
			});
		},
		closestNodeId = function (nodeList, referenceNode) {
			const closestNode = _.min(nodeList, function (node) {
				return Math.pow(node.x + node.width / 2 - referenceNode.x - referenceNode.width / 2, 2)
					+ Math.pow(node.y + node.height / 2 - referenceNode.y - referenceNode.height / 2, 2);
			});
			return closestNode && closestNode.id;
		},
		updateCurrentLayout = function (newLayout, sessionId, themeChanged) {
			let layoutCompleteOptions;
			const currentLayout = layoutModel.getLayout(),
				nodePositionsChanged = (oldNode, newNode) => {
					if (!oldNode || !newNode) {
						return false;
					}
					return (newNode.x !== oldNode.x || newNode.y !== oldNode.y);
				},
				connectorNodeMoved = (oldConnector, newConnector) => {
					if (!oldConnector || !newConnector || oldConnector.from !== newConnector.from || oldConnector.to !== newConnector.to) {
						return false;
					}
					const oldFromNode = currentLayout.nodes[oldConnector.from],
						oldToNode = currentLayout.nodes[oldConnector.to],
						newFromNode = newLayout.nodes[newConnector.from],
						newToNode = newLayout.nodes[newConnector.to];
					return nodePositionsChanged(oldFromNode, newFromNode) || nodePositionsChanged(oldToNode, newToNode);
				};

			self.dispatchEvent('layoutChangeStarting', _.size(newLayout.nodes) - _.size(currentLayout.nodes));
			applyLabels(newLayout);
			_.each(currentLayout.connectors, function (oldConnector, connectorId) {
				const newConnector = newLayout.connectors && newLayout.connectors[connectorId];
				if (!newConnector || newConnector.from !== oldConnector.from || newConnector.to !== oldConnector.to) {
					self.dispatchEvent('connectorRemoved', oldConnector);
				}
			});
			_.each(currentLayout.links, function (oldLink, linkId) {
				const newLink = newLayout.links && newLayout.links[linkId];
				if (!newLink) {
					self.dispatchEvent('linkRemoved', oldLink);
				}
			});
			_.each(currentLayout.nodes, function (oldNode, nodeId) {
				const newNode = newLayout.nodes[nodeId];
				let newActive;
				if (!newNode) {
					/*jslint eqeq: true*/
					if (nodeId == currentlySelectedIdeaId) { //eslint-disable-line eqeqeq
						self.selectNode(closestNodeId(newLayout.nodes, oldNode));
					}
					newActive = _.reject(activatedNodes, function (e) {
						return e == nodeId; // eslint-disable-line eqeqeq
					});
					if (newActive.length !== activatedNodes.length) {
						setActiveNodes(newActive);
					}
					self.dispatchEvent('nodeRemoved', oldNode, nodeId, sessionId);
				}
			});

			_.each(newLayout.nodes, function (newNode, nodeId) {
				const oldNode = currentLayout.nodes[nodeId];
				if (!oldNode) {
					self.dispatchEvent('nodeCreated', newNode, sessionId);
				} else {
					if (nodePositionsChanged(newNode, oldNode)) {
						self.dispatchEvent('nodeMoved', newNode, sessionId);
					}
					if ((newNode.width !== oldNode.width || newNode.height !== oldNode.height) ||
						(newNode.level !== oldNode.level) ||
						(!_.isEqual(newNode.attr || {}, oldNode.attr || {})) ||
						themeChanged) {
						self.dispatchEvent('nodeAttrChanged', newNode, sessionId);
					}
					if (newNode.title !== oldNode.title) {
						self.dispatchEvent('nodeTitleChanged', newNode, sessionId);
					}
					if (newNode.label !== oldNode.label) {
						self.dispatchEvent('nodeLabelChanged', newNode, sessionId);
					}
				}
			});
			_.each(newLayout.connectors, function (newConnector, connectorId) {
				const oldConnector = currentLayout.connectors[connectorId];
				if (oldConnector && !_.isEqual(oldConnector.attr || {}, newConnector.attr || {})) {
					self.dispatchEvent('connectorAttrChanged', newConnector);
				} else if (connectorNodeMoved(oldConnector, newConnector)) {
					self.dispatchEvent('connectorMoved', newConnector);
				}
				if (!oldConnector || newConnector.from !== oldConnector.from || newConnector.to !== oldConnector.to) {
					self.dispatchEvent('connectorCreated', newConnector, sessionId);
				}
			});
			_.each(newLayout.links, function (newLink, linkId) {
				const oldLink = currentLayout.links && currentLayout.links[linkId];
				if (oldLink) {
					if (!_.isEqual(newLink.attr || {}, (oldLink && oldLink.attr) || {})) {
						self.dispatchEvent('linkAttrChanged', newLink, sessionId);
					}
				} else {
					self.dispatchEvent('linkCreated', newLink, sessionId);
				}
			});
			if (themeChanged) {
				layoutCompleteOptions = { themeChanged: true };
			}
			layoutModel.setLayout(newLayout);
			// Logging node layout to console to help with debugging:
			// Utilities.idea_pp(idea);
			if (!self.isInCollapse) {
				self.dispatchEvent('layoutChangeComplete', layoutCompleteOptions);
			}
		},
		selectNewIdea = function (newIdeaId) {
			revertSelectionForUndo = currentlySelectedIdeaId;
			revertActivatedForUndo = activatedNodes.slice(0);
			self.selectNode(newIdeaId);
		},
		editNewIdea = function (newIdeaId) {
			selectNewIdea(newIdeaId);
			self.editNode(false, true, true);
		},
		getCurrentlySelectedIdeaId = function () {
			return currentlySelectedIdeaId || idea.getDefaultRootId();
		},
		onIdeaChanged = function (action, args, sessionId) {
			if (paused) {
				return;
			}
			revertSelectionForUndo = false;
			revertActivatedForUndo = false;
			self.rebuildRequired(sessionId);
		},
		currentlySelectedIdea = function () {
			return (idea.findSubIdeaById(currentlySelectedIdeaId) || idea);
		},
		ensureNodeIsExpanded = function (source, nodeId) {
			const node = idea.findSubIdeaById(nodeId) || idea;
			if (node.getAttr('collapsed')) {
				idea.updateAttr(nodeId, 'collapsed', false);
			}
		},
		addSubIdeaToTargetNode = function (source, targetId, initialTitle) {
			const targetNode = idea.findSubIdeaById(targetId) || idea;
			let newId;
			ensureNodeIsExpanded(source, targetId);
			if (initialTitle) {
				newId = addSubIdea(targetId, initialTitle);
			} else {
				newId = addSubIdea(targetId);
			}
			if (layoutModel.getOrientation() === 'top-down') {
				if (targetNode.findChildRankById(newId) < 0) {
					idea.flip(newId);
				}
			}
			return newId;
		},
		setNodePositionFromCurrentLayout = function (nodeId) {
			const node = nodeId && layoutModel.getNode(nodeId);
			if (node) {
				idea.updateAttr(nodeId, 'position', [node.x, node.y, 1]);
			}
		},
		positionNextTo = function (nodeId, relativeNodeId) {
			const relativeNode = relativeNodeId && layoutModel.getNode(relativeNodeId);
			if (relativeNode) {
				idea.updateAttr(nodeId, 'position', [relativeNode.x + relativeNode.width + 2 * reorderMargin, relativeNode.y, 1]);
			}
		},
		analytic = function (eventName, eventArg) {
			if (eventArg) {
				self.dispatchEvent('analytic', 'mapModel', eventName, eventArg);
			} else {
				self.dispatchEvent('analytic', 'mapModel', eventName);
			}
		};
	observable(this);
	self.pause = function () {
		paused = true;
	};
	self.resume = function () {
		paused = false;
		self.rebuildRequired();
	};
	self.getIdea = function () {
		return idea;
	};
	self.isEditingEnabled = function () {
		return isEditingEnabled;
	};
	self.getCurrentLayout = function () {
		return layoutModel.getLayout();
	};
	self.analytic = analytic;
	self.getCurrentlySelectedIdeaId = getCurrentlySelectedIdeaId;
	self.rebuildRequired = function (sessionId) {
		if (!idea) {
			return;
		}
		const currentLayout = layoutModel.getLayout(),
			themeHasChanged = currentLayout.theme !== (idea.attr && idea.attr.theme),
			ideaThemeOverrides = idea.attr && idea.attr.themeOverrides,
			layoutThemeOverrides = currentLayout && currentLayout.themeOverrides,
			themeOverridesHaveChanged = !_.isEqual(ideaThemeOverrides || {}, layoutThemeOverrides || {}),
			themeChanged = themeHasChanged || themeOverridesHaveChanged;
		if (themeChanged) {
			self.dispatchEvent('themeChanged', idea.attr && idea.attr.theme, idea.attr && idea.attr.themeOverrides);
		}
		updateCurrentLayout(self.reactivate(layoutCalculator(idea)), sessionId, themeChanged);
	};
	this.setIdea = function (anIdea, tryKeepingContext) {
		const oldSelectedIdea = currentlySelectedIdeaId;
		if (!layoutCalculator) {
			throw new Error('layout calculator not set');
		};
		if (idea) {
			idea.removeEventListener('changed', onIdeaChanged);
			paused = false;
			setActiveNodes([]);
			self.dispatchEvent('nodeSelectionChanged', currentlySelectedIdeaId, false);
			currentlySelectedIdeaId = undefined;
		}
		idea = anIdea;
		idea.addEventListener('changed', onIdeaChanged);
		onIdeaChanged();
		if (tryKeepingContext && idea.findSubIdeaById(oldSelectedIdea)) {
			self.selectNode(oldSelectedIdea, true);
		} else {
			self.selectNode(idea.getDefaultRootId(), true);
			self.dispatchEvent('mapViewResetRequested');
		}

	};
	this.setEditingEnabled = function (value) {
		isEditingEnabled = value;
	};
	this.getEditingEnabled = function () {
		return isEditingEnabled;
	};
	this.setInputEnabled = function (source, dataset, value, holdFocus) {
		(typeof value === 'undefined') ? value = dataset.setInputEnabled === 'true' : undefined;
		if (isInputEnabled !== value) {
			isInputEnabled = value;
			self.dispatchEvent('inputEnabledChanged', value, !!holdFocus);
		}
	};
	this.getInputEnabled = function () {
		return isInputEnabled;
	};
	this.selectNode = function (id, force, appendToActive) {
		if (force || (isInputEnabled && (id !== currentlySelectedIdeaId || !self.isActivated(id)))) {
			if (currentlySelectedIdeaId) {
				self.dispatchEvent('nodeSelectionChanged', currentlySelectedIdeaId, false);
			}
			currentlySelectedIdeaId = id;
			if (appendToActive) {
				self.activateNode('internal', id);
			} else {
				setActiveNodes([id]);
			}

			self.dispatchEvent('nodeSelectionChanged', id, true);
		}
	};
	// This seems to be triggered by mouseup not mousedown
	this.clickNode = function (id, event) {
		const button = event && event.button && event.button !== -1,
			// 'which', unlike button, seems to get populated on mouse up.
			which = event.which;
		if (event && event.altKey) {
			self.toggleLink('mouse', id);
		} else if (event && event.shiftKey) {
			/*don't stop propagation, this is needed for drop targets*/
			self.toggleActivationOnNode('mouse', id);
		} else if (isAddLinkMode && !button) { // Removed in commit 354071624edb6c257441fcdfcb3f11ab92ad395e, restored to enable add link button. Using which instead of button stops it working.
			this.toggleLink('mouse', id);
			this.toggleAddLinkMode();
		} else if (which) {
			this.selectNode(id);
			if (button && button !== -1 && isInputEnabled) {
				self.dispatchEvent('contextMenuRequested', id, event.layerX, event.layerY);
			}
		} else {
			self.dispatchEvent('nodeClicked', id, event);
		}
	};
	this.findIdeaById = function (id) {
		if (idea.id == id) { //eslint-disable-line eqeqeq
			return idea;
		}
		return idea.findSubIdeaById(id);
	};
	this.getSelectedStyle = function (prop) {
		return this.getStyleForId(currentlySelectedIdeaId, prop);
	};
	this.getStyleForId = function (id, prop) {
		const node = layoutModel.getNode(id);
		return node && node.attr && node.attr.style && node.attr.style[prop];
	};
	this.toggleCollapse = function (source) {
		const selectedIdea = currentlySelectedIdea();
		let isCollapsed;
		if (self.isActivated(selectedIdea.id) && _.size(selectedIdea.ideas) > 0) {
			isCollapsed = selectedIdea.getAttr('collapsed');
		} else {
			isCollapsed = self.everyActivatedIs(function (id) {
				const node = self.findIdeaById(id);
				if (node && _.size(node.ideas) > 0) {
					return node.getAttr('collapsed');
				}
				return true;
			});
		}
		this.collapse(source, !isCollapsed);
	};
	this.collapse = function (source, doCollapse) {
		const contextNodeId = getCurrentlySelectedIdeaId(),
			contextNode = function () {
				return layoutModel.getNode(contextNodeId);
			},
			moveNodes = function (nodes, deltaX, deltaY) {
				if (deltaX || deltaY) {
					_.each(nodes, function (node) {
						node.x += deltaX;
						node.y += deltaY;
						self.dispatchEvent('nodeMoved', node, 'scroll');
					});
				}
			},
			moveConnectors = function (connectors) {
				if (!connectors) {
					return;
				}
				Object.keys(connectors).forEach(key => self.dispatchEvent('connectorMoved', connectors[key]));
			},
			oldContext = contextNode();
		let newContext = false;
		analytic('collapse:' + doCollapse, source);
		self.isInCollapse = true;
		if (isInputEnabled) {
			self.applyToActivated(function (id) {
				const node = self.findIdeaById(id);
				if (node && (!doCollapse || (node.ideas && _.size(node.ideas) > 0))) {
					idea.updateAttr(id, 'collapsed', doCollapse);
				}
			});
		}
		newContext = contextNode();
		if (oldContext && newContext) {
			moveNodes(
				layoutModel.getLayout().nodes,
				oldContext.x - newContext.x,
				oldContext.y - newContext.y
			);
			moveConnectors(layoutModel.getLayout().connectors);
		}
		self.isInCollapse = false;
		self.dispatchEvent('layoutChangeComplete');
	};
	this.updateStyle = function (source, prop, value) {
		/*jslint eqeq:true */
		if (!isEditingEnabled) {
			return false;
		}
		if (isInputEnabled) {
			analytic('updateStyle:' + prop, source);
			self.applyToActivated(function (id) {
				if (self.getStyleForId(id, prop) != value) { //eslint-disable-line eqeqeq
					idea.mergeAttrProperty(id, 'style', prop, value);
				}
			});
		}
	};
	this.updateLinkStyle = function (source, ideaIdFrom, ideaIdTo, prop, value) {
		const merged = _.extend({}, idea.getLinkAttr(ideaIdFrom, ideaIdTo, 'style'));
		if (!isEditingEnabled) {
			return false;
		}
		if (isInputEnabled) {
			analytic('updateLinkStyle:' + prop, source);
			if (prop === 'arrow') {
				// If arrow button pressed, toggle arrow value.
				value = merged.arrow ? false : 'to';
			}
			merged[prop] = value;
			idea.updateLinkAttr(ideaIdFrom, ideaIdTo, 'style', merged);
		}
	};
	this.addSubIdea = function (source, parentId, initialTitle) {
		const target = parentId || currentlySelectedIdeaId;
		let newId;
		if (!isEditingEnabled) {
			return false;
		}
		analytic('addSubIdea', source);
		if (isInputEnabled) {
			idea.batch(function () {
				newId = addSubIdeaToTargetNode(source, target, initialTitle);
				setRootNodePositionsForPrecalculatedLayout(newId);
			});
			if (newId) {
				if (initialTitle) {
					selectNewIdea(newId);
				} else {
					editNewIdea(newId);
				}
			}
		}

	};
	self.addGroupSubidea = function (source, options) {
		const parentId = options && options.parentId,
			group = (options && options.group) || true,
			target = parentId || currentlySelectedIdeaId;
		let newGroupId, newId;
		if (!isEditingEnabled) {
			return false;
		}
		analytic('addGroupSubidea', source);
		if (isInputEnabled) {
			idea.batch(function () {
				newGroupId = addSubIdeaToTargetNode(source, target, 'group');
				if (newGroupId) {
					idea.updateAttr(newGroupId, 'contentLocked', true);
					idea.updateAttr(newGroupId, 'group', group);
					newId = addSubIdea(newGroupId);
				}
				setRootNodePositionsForPrecalculatedLayout(newId);
			});
			if (newId) {
				editNewIdea(newId);
			}
		}

	};
	// Button removed since current functionality not very useful
	// this.insertIntermediateGroup = function (source, options) {
	// 	const activeNodes = [],
	// 		group = (options && options.group) || true;
	// 	if (!isEditingEnabled) {
	// 		return false;
	// 	}
	// 	// This line stops parent reason being added to root node:
	// 	// if (!isInputEnabled || idea.isRootNode(currentlySelectedIdeaId)) {
	// 	if (!isInputEnabled) {
	// 		return false;
	// 	}
	// 	analytic('insertIntermediate', source);
	// 	self.applyToActivated(function (i) {
	// 		activeNodes.push(i);
	// 	});
	// 	insertIntermediateMultiple(activeNodes, { title: 'group', attr: { group: group, contentLocked: true } });
	// };
	this.insertIntermediate = function (source) {
		const activeNodes = [];
		let newId = false;
		if (!isEditingEnabled) {
			return false;
		}
		if (!isInputEnabled) {
			return false;
		}
		analytic('insertIntermediate', source);
		self.applyToActivated(function (i) {
			activeNodes.push(i);
		});
		newId = insertIntermediateMultiple(activeNodes);
		if (newId) {
			editNewIdea(newId);
		}
	};
	this.flip = function (source) {
		const node = layoutModel.getNode(currentlySelectedIdeaId);

		if (!isEditingEnabled) {
			return false;
		}
		analytic('flip', source);
		if (!isInputEnabled || idea.isRootNode(currentlySelectedIdeaId)) {
			return false;
		}
		if (!node || node.level !== 2) {
			return false;
		}

		return idea.flip(currentlySelectedIdeaId);
	};
	this.addSiblingIdeaBefore = function (source) {
		let newId, parent, contextRank, newRank;
		if (!isEditingEnabled) {
			return false;
		}
		analytic('addSiblingIdeaBefore', source);
		if (!isInputEnabled) {
			return false;
		}
		if (idea.isRootNode(currentlySelectedIdeaId)) {
			parent = idea;
		} else {
			parent = idea.findParent(currentlySelectedIdeaId);
		}
		idea.batch(function () {
			if (parent !== idea) {
				ensureNodeIsExpanded(source, parent.id);
			}
			newId = addSubIdea(parent.id);
			if (newId) {
				if (parent === idea) {
					positionNextTo(newId, currentlySelectedIdeaId);
				} else {
					contextRank = parent.findChildRankById(currentlySelectedIdeaId);
					newRank = parent.findChildRankById(newId);
					if (contextRank * newRank < 0) {
						idea.flip(newId);
					}
					idea.positionBefore(newId, currentlySelectedIdeaId);
				}
				setRootNodePositionsForPrecalculatedLayout(newId);
			}
		});
		if (newId) {
			editNewIdea(newId);
		}
	};
	this.addSiblingIdea = function (source, optionalNodeId, optionalInitialText) {
		let newId, nextId, parent, contextRank, newRank;
		const currentId = optionalNodeId || currentlySelectedIdeaId;
		if (!isEditingEnabled) {
			return false;
		}
		analytic('addSiblingIdea', source);
		if (isInputEnabled) {

			if (idea.isRootNode(currentId)) {
				parent = idea;
			} else {
				parent = idea.findParent(currentId);
			}
			idea.batch(function () {
				if (parent !== idea) {
					ensureNodeIsExpanded(source, parent.id);
				}
				if (optionalInitialText) {
					newId = addSubIdea(parent.id, optionalInitialText);
				} else {
					newId = addSubIdea(parent.id);
				}
				if (newId) {
					if (parent === idea) {
						positionNextTo(newId, currentlySelectedIdeaId);
					} else {
						nextId = idea.nextSiblingId(currentId);
						contextRank = parent.findChildRankById(currentId);
						newRank = parent.findChildRankById(newId);
						if (contextRank * newRank < 0) {
							idea.flip(newId);
						}
						if (nextId) {
							idea.positionBefore(newId, nextId);
						}
					}
					setRootNodePositionsForPrecalculatedLayout(newId);
				}
			});
			if (newId) {
				if (optionalInitialText) {
					selectNewIdea(newId);
				} else {
					editNewIdea(newId);
				}
			}
		}
	};
	this.removeSubIdea = function (source) {
		let removed;
		if (!isEditingEnabled) {
			return false;
		}
		analytic('removeSubIdea', source);
		if (isInputEnabled) {
			self.applyToActivated(function (id) {
				removed = idea.removeSubIdea(id);
			});
		}
		return removed;
	};
	this.updateTitle = function (ideaId, title, isNew) {
		idea.batch(() => {
			if (isNew) {
				idea.initialiseTitle(ideaId, title);
			} else {
				idea.updateTitle(ideaId, title);
			}
			setRootNodePositionsForPrecalculatedLayout(ideaId);
		});
	};
	this.editNode = function (source, shouldSelectAll, editingNew) {
		const currentIdea = currentlySelectedIdea(),
			title = currentIdea.title;
		if (!isEditingEnabled) {
			return false;
		}
		if (source) {
			analytic('editNode', source);
		}
		if (!isInputEnabled) {
			return false;
		}

		if (currentIdea.attr && currentIdea.attr.contentLocked) {
			return false;
		}

		if (_.include(selectAllTitles, title)) { // === 'Press Space or double-click to edit') {
			shouldSelectAll = true;
		}
		self.dispatchEvent('nodeEditRequested', currentlySelectedIdeaId, shouldSelectAll, !!editingNew);
	};
	// this.editIcon = function (source) {
	// 	if (!isEditingEnabled) {
	// 		return false;
	// 	}
	// 	if (source) {
	// 		analytic('editIcon', source);
	// 	}
	// 	if (!isInputEnabled) {
	// 		return false;
	// 	}
	// 	self.dispatchEvent('nodeIconEditRequested', currentlySelectedIdeaId);
	// };
	this.scaleUp = function (source) {
		self.scale(source, 1.25);
	};
	this.scaleDown = function (source) {
		self.scale(source, 0.8);
	};
	this.scale = function (source, scaleMultiplier, zoomPoint) {
		if (isInputEnabled) {
			self.dispatchEvent('mapScaleChanged', scaleMultiplier, zoomPoint);
			analytic(scaleMultiplier < 1 ? 'scaleDown' : 'scaleUp', source);
		}
	};
	this.move = function (source, deltaX, deltaY) {
		if (isInputEnabled) {
			self.dispatchEvent('mapMoveRequested', deltaX, deltaY);
			analytic('move', source);
		}
	};
	this.resetView = function (source) {
		const selectedNode = layoutModel.getNode(currentlySelectedIdeaId),
			localRoot = (selectedNode && selectedNode.rootId) || (idea && idea.getDefaultRootId());
		if (!localRoot) {
			return;
		}
		if (isInputEnabled) {
			analytic('resetView', source);
			self.selectNode(localRoot);
			self.dispatchEvent('mapViewResetRequested');
		}
	};
	this.decorationAction = function (source, nodeId, decorationType) {
		analytic('decorationAction', source);
		self.dispatchEvent('decorationActionRequested', nodeId, decorationType);
	};

	// This now only needed for `alt+o` shortcut, since file input can be tabbed to while pretending that 'Load' button is selected.
	// 	So container no longer needed as argument but leaving in for now.
	this.handleKey_loadMap = function (source, event, container) {
		analytic('handleKeyLoadMap', source);
		// const container = event.currentTarget,
		const fileButton = container.getElementsByClassName('readFile')[0];
		fileButton.click();
	};

	// TODO: Add support for multiple files
	// 	When the (file input element) multiple Boolean attribute is specified, the file input allows the user to select more than one file.
	// 	Could either load them as separate map roots, or open a container for each one
	//  	If load is part of toolbar then only former makes sense
	this.readFile = function (source, data_target, filename, event) {
		analytic('loadMap', source);
		const fileList = event.target.files;
		if (fileList.length > 0) { // fileList can change from a file to no file
			const file = fileList[0],
				reader = new window.FileReader;

			reader.onload = function () {
				self.loadMap(reader.result, data_target, true);
			};

			// Think this triggers the onload, but not certain:
			reader.readAsText(file);
		}
	};

	// TODO: Need to re-use some of this in combination with addMap(), drag and drop, cut and paste.
	// TODO: Should have error catching/sanitation for file type/data
	// Called by `readFile()` above and also client_argmap2mapjs.lua
	this.loadMap = function (mapJson, target_container_id, replace) {
		const mapM = this,
			old_idea = mapM.getIdea();

		// Batch ensures that operations are atomic
		// So counts as a single undo/redo step
		return old_idea.batch(function () {
			if (replace) {
				// Was hoping that nesting this inside batch would enable undo, but does not.
				const new_idea = mapM.content(JSON.parse(mapJson));
				mapM.setIdea(new_idea);
			} else {
				old_idea.pasteMultiple('root', JSON.parse(mapJson).ideas);
				mapM.removeSubIdea('root', 'loadMap');
			}
		});

		return true;
	};
	this.downloadMap = function (source) {
		analytic('downloadMap', source);
		const mapJson = this.getIdea(),
			mapOutput = JSON.stringify(mapJson);
		Utilities.downloadToFile(mapOutput, mapJson.title + '.json', 'application/json');
	};
	// Not currently very useful, so removed button:
	// this.openAttachment = function (source, nodeId) {
	// 	analytic('openAttachment', source);
	// 	nodeId = nodeId || currentlySelectedIdeaId;
	// 	const node = layoutModel.getNode(nodeId),
	// 		attachment = node && node.attr && node.attr.attachment;
	// 	if (node) {
	// 		self.dispatchEvent('attachmentOpened', nodeId, attachment);
	// 	}
	// };
	// this.setAttachment = function (source, nodeId, attachment) {
	// 	const hasAttachment = !!(attachment && (attachment.content || attachment.goldAssetId));
	// 	if (!isEditingEnabled) {
	// 		return false;
	// 	}
	// 	analytic('setAttachment', source);
	// 	idea.updateAttr(nodeId, 'attachment', hasAttachment && attachment);
	// };
	this.toggleLink = function (source, nodeIdTo) {
		const exists = _.find(idea.links, function (link) {
			return (String(link.ideaIdFrom) === String(nodeIdTo) && String(link.ideaIdTo) === String(currentlySelectedIdeaId)) || (String(link.ideaIdTo) === String(nodeIdTo) && String(link.ideaIdFrom) === String(currentlySelectedIdeaId));
		});
		if (exists) {
			self.removeLink(source, exists.ideaIdFrom, exists.ideaIdTo);
		} else {
			self.addLink(source, nodeIdTo);
		}
	};
	this.addLink = function (source, nodeIdTo) {
		if (!isEditingEnabled) {
			return false;
		}
		analytic('addLink', source);
		idea.addLink(currentlySelectedIdeaId, nodeIdTo);
	};

	this.selectLink = function (source, link, selectionPoint) {
		if (!isEditingEnabled) {
			return false;
		}
		analytic('selectLink', source);
		if (!link) {
			return false;
		}

		// Remove class 'selected' from previously selected link, add it to newly selected link
		//	Also node IDs can contain dots ('.') so rewrite ID . with _, consistent with how they appear in HTML.
		// QUESTION: Should this be toggle so two clicks would unselect?
		// 	Would need to change link-edit-widget behaviour too.
		const link_id = [link.type, link.ideaIdFrom, link.ideaIdTo].join('_').replaceAll('.', '_'),
			// Unfortunately links are not guaranteed to have a unique ID, because code was written assuming a single container on the page, but now supports multiple containers, which may have links between identical node IDs.
			// Can  identify current container using this.container_element (which is assigned in start.js), so that only relevant links are affected:
			// Can only use getElementById at doc level so using querySelector instead:
			link_element = this.containerElement.querySelector('#' + link_id);
		if (link_element && !link_element.classList.contains('selected-link')) {
			// TODO: Would be more efficient to remember the selected link and then remove the class from it without having to find it again.
			const old_selected_link = this.containerElement.getElementsByClassName('selected-link')[0];
			(old_selected_link ? old_selected_link.classList.remove('selected-link') : undefined);
			link_element.classList.add('selected-link');
		};
		self.dispatchEvent('linkSelected', link, selectionPoint, idea.getLinkAttr(link.ideaIdFrom, link.ideaIdTo, 'style'));
	};

	this.selectConnector = function (source, connector, selectionPoint) {
		if (!isEditingEnabled) {
			return false;
		}
		analytic('selectConnector', source);
		if (!connector) {
			return false;
		}
		self.dispatchEvent('connectorSelected', connector, selectionPoint, idea.getAttrById(connector.to, 'parentConnector'));
	};
	this.removeLink = function (source, nodeIdFrom, nodeIdTo) {
		if (!isEditingEnabled) {
			return false;
		}
		analytic('removeLink', source);
		idea.removeLink(nodeIdFrom, nodeIdTo);
	};

	this.toggleAddLinkMode = function (source) {
		if (!isEditingEnabled) {
			return false;
		}
		if (!isInputEnabled) {
			return false;
		}
		analytic('toggleAddLinkMode', source);
		isAddLinkMode = !isAddLinkMode;
		self.dispatchEvent('addLinkModeToggled', isAddLinkMode);
	};
	this.cancelCurrentAction = function (source) {
		if (!isInputEnabled) {
			return false;
		}
		if (!isEditingEnabled) {
			return false;
		}
		if (isAddLinkMode) {
			this.toggleAddLinkMode(source);
		}
	};

	self.undo = function (source) {
		const undoSelectionClone = revertSelectionForUndo,
			undoActivationClone = revertActivatedForUndo;
		if (!isEditingEnabled) {
			return false;
		}
		analytic('undo', source);
		if (isInputEnabled) {
			idea.undo();
			if (undoSelectionClone) {
				self.selectNode(undoSelectionClone);
			}
			if (undoActivationClone) {
				setActiveNodes(undoActivationClone);
			}

		}
	};
	self.redo = function (source) {
		if (!isEditingEnabled) {
			return false;
		}

		analytic('redo', source);
		if (isInputEnabled) {
			idea.redo();
		}
	};
	self.moveRelative = function (source, relativeMovement) {
		let options;
		if (!isEditingEnabled) {
			return false;
		}
		analytic('moveRelative', source);
		if (isInputEnabled) {
			if (layoutModel.getOrientation() === 'top-down') {
				options = { ignoreRankSide: true };
			}
			idea.moveRelative(currentlySelectedIdeaId, relativeMovement, options);
		}
	};
	self.cut = function (source) {
		const activeNodeIds = [], parents = [];
		if (!isEditingEnabled) {
			return false;
		}
		analytic('cut', source);
		if (isInputEnabled) {
			self.applyToActivated(function (nodeId) {
				activeNodeIds.push(nodeId);
				parents.push(idea.findParent(nodeId).id);
			});
			clipboard.put(idea.cloneMultiple(activeNodeIds));
			idea.removeMultiple(activeNodeIds);
		}
	};
	self.contextForNode = function (nodeId) {
		const node = self.findIdeaById(nodeId),
			hasChildren = node && node.ideas && _.size(node.ideas) > 0,
			rootCount = _.size(idea.ideas),
			hasSiblings = idea.hasSiblings(nodeId),
			hasPreferredWidth = node && node.attr && node.attr.style && node.attr.style.width,
			hasPosition = node && node.attr && node.attr.position,
			isCollapsed = node && node.getAttr('collapsed'),
			canPaste = node && isEditingEnabled && clipboard && clipboard.get(),
			isRoot = idea.isRootNode(nodeId);
		if (node) {
			return {
				hasChildren: !!hasChildren,
				hasSiblings: !!hasSiblings,
				hasPreferredWidth: !!hasPreferredWidth,
				canPaste: !!canPaste,
				hasPreferredPosition: !!hasPosition,
				notRoot: !isRoot,
				notLastRoot: !isRoot || (rootCount > 1),
				canUndo: idea.canUndo() && !revertSelectionForUndo,
				canRedo: idea.canRedo() && !revertSelectionForUndo,
				canCollapse: hasChildren && !isCollapsed,
				canExpand: hasChildren && isCollapsed
			};
		}

	};
	self.copy = function (source) {
		const activeNodeIds = [];
		if (!isEditingEnabled) {
			return false;
		}
		analytic('copy', source);
		if (isInputEnabled) {
			self.applyToActivated(function (node) {
				activeNodeIds.push(node);
			});
			clipboard.put(idea.cloneMultiple(activeNodeIds));
		}
	};
	self.paste = function (source) {
		let result;
		if (!isEditingEnabled) {
			return false;
		}
		analytic('paste', source);
		if (isInputEnabled) {
			result = idea.pasteMultiple(currentlySelectedIdeaId, clipboard.get());
			if (result && result[0]) {
				self.selectNode(result[0]);
			}
		}
		return result;
	};
	self.pasteStyle = function (source) {
		const clipContents = clipboard.get();
		let pastingStyle;
		if (!isEditingEnabled) {
			return false;
		}
		analytic('pasteStyle', source);
		if (isInputEnabled && clipContents && clipContents[0]) {
			pastingStyle = clipContents[0].attr && clipContents[0].attr.style;
			self.applyToActivated(function (id) {
				idea.updateAttr(id, 'style', pastingStyle);
			});
		}
	};
	self.getIcon = function (nodeId) {
		const node = layoutModel.getNode(nodeId || currentlySelectedIdeaId);
		if (!node) {
			return false;
		}
		return node.attr && node.attr.icon;
	};
	self.setIcon = function (source, url, imgWidth, imgHeight, position, nodeId, metaData) {
		let nodeIdea = false, iconObject;
		if (!isEditingEnabled) {
			return false;
		}
		analytic('setIcon', source);
		nodeId = nodeId || currentlySelectedIdeaId;
		nodeIdea = self.findIdeaById(nodeId);
		if (!nodeIdea) {
			return false;
		}
		if (url) {
			iconObject = {
				url: url,
				width: imgWidth,
				height: imgHeight,
				position: position
			};
			if (metaData) {
				iconObject.metaData = metaData;
			}
			idea.updateAttr(nodeId, 'icon', iconObject);
		} else {
			idea.updateAttr(nodeId, 'icon', false);
			if (!nodeIdea.title && _.size(nodeIdea.ideas) === 0) {
				idea.removeSubIdea(nodeId);
			}
		}
	};
	self.insertUp = function (source) {
		if (layoutModel.getOrientation() === 'standard') {
			self.addSiblingIdeaBefore(source);
		} else {
			self.insertIntermediate(source);
		}
	};
	self.insertDown = function (source) {
		if (layoutModel.getOrientation() === 'standard') {
			self.addSiblingIdea(source);
		} else {
			self.addSubIdea(source);
		}
	};
	self.insertLeft = function (source) {
		if (layoutModel.getOrientation() === 'standard') {
			self.insertIntermediate(source);
		} else {
			self.addSiblingIdeaBefore(source);
		}
	};
	self.insertRight = function (source) {
		if (layoutModel.getOrientation() === 'standard') {
			self.addSubIdea(source);
		} else {
			self.addSiblingIdea(source);
		}
	};
	self.moveUp = function (source) {
		if (layoutModel.getOrientation() === 'standard') {
			self.moveRelative(source, -1);
		}
	};
	self.moveDown = function (source) {
		if (layoutModel.getOrientation() === 'standard') {
			self.moveRelative(source, 1);
		}
	};
	self.moveLeft = function (source) {
		if (layoutModel.getOrientation() === 'standard') {
			self.flip(source);
		} else {
			self.moveRelative(source, -1);
		}
	};
	self.moveRight = function (source) {
		if (layoutModel.getOrientation() === 'standard') {
			self.flip(source);
		} else {
			self.moveRelative(source, 1);
		}
	};
	self.getSelectedNodeId = function () {
		return getCurrentlySelectedIdeaId();
	};
	self.centerOnNode = function (nodeId) {
		if (!layoutModel.getNode(nodeId)) {
			idea.startBatch();
			_.each(idea.calculatePath(nodeId), function (parent) {
				idea.updateAttr(parent.id, 'collapsed', false);
			});
			idea.endBatch();
		}
		self.dispatchEvent('nodeFocusRequested', nodeId);
		self.selectNode(nodeId);
	};
	self.search = function (query) {
		const result = [];
		query = query.toLocaleLowerCase();
		idea.traverse(function (contentIdea) {
			if (contentIdea.title && contentIdea.title.toLocaleLowerCase().indexOf(query) >= 0) {
				result.push({ id: contentIdea.id, title: contentIdea.title });
			}
		});
		return result;
	};
	//node activation and selection
	(function () {
		const applyToNodeDirection = function (source, analyticTag, method, direction) {
				if (!isInputEnabled) {
					return;
				}
				analytic(analyticTag, source);
				const relId = layoutModel['nodeId' + direction](currentlySelectedIdeaId);
				if (relId) {
					method.apply(self, [relId]);
				}
			},
			applyFuncs = {};

		['Left', 'Right', 'Up', 'Down'].forEach(function (direction) {
			applyFuncs[direction] = function (source, analyticTag, method) {
				applyToNodeDirection(source, analyticTag, method, direction);
			};
		});
		self.getActivatedNodeIds = function () {
			return activatedNodes.slice(0);
		};
		self.activateSiblingNodes = function (source) {
			const parent = idea.findParent(currentlySelectedIdeaId),
				siblingIds = parent && parent.ideas && _.map(parent.ideas, function (child) {
					return child.id;
				});

			analytic('activateSiblingNodes', source);
			if (!siblingIds) {
				return;
			}
			setActiveNodes(siblingIds);
		};
		self.activateNodeAndChildren = function (source) {
			const contextId = getCurrentlySelectedIdeaId(),
				subtree = idea.getSubTreeIds(contextId);
			analytic('activateNodeAndChildren', source);
			subtree.push(contextId);
			setActiveNodes(subtree);
		};
		_.each(['Left', 'Right', 'Up', 'Down'], function (position) {
			self['activateNode' + position] = function (source) {
				applyFuncs[position](source, 'activateNode' + position, function (nodeId) {
					self.selectNode(nodeId, false, true);
				});
			};
			self['selectNode' + position] = function (source) {
				applyFuncs[position](source, 'selectNode' + position, self.selectNode);
			};
		});

		self.toggleActivationOnNode = function (source, nodeId) {
			analytic('toggleActivated', source);
			if (!self.isActivated(nodeId)) {
				setActiveNodes([nodeId].concat(activatedNodes));
			} else {
				setActiveNodes(_.without(activatedNodes, nodeId));
			}
		};
		self.activateNode = function (source, nodeId) {
			analytic('activateNode', source);
			if (!self.isActivated(nodeId)) {
				activatedNodes.push(nodeId);
				self.dispatchEvent('activatedNodesChanged', [nodeId], []);
			}
		};
		self.activateChildren = function (source) {
			const context = currentlySelectedIdea();
			analytic('activateChildren', source);
			if (!context || _.isEmpty(context.ideas) || context.getAttr('collapsed')) {
				return;
			}
			setActiveNodes(idea.getSubTreeIds(context.id));
		};
		self.activateSelectedNode = function (source) {
			analytic('activateSelectedNode', source);
			setActiveNodes([getCurrentlySelectedIdeaId()]);
		};
		self.isActivated = function (id) {
			return _.find(activatedNodes, function (activeId) {
				return id == activeId; //eslint-disable-line eqeqeq
			});
		};
		self.applyToActivated = function (toApply) {
			idea.batch(function () {
				_.each(activatedNodes, toApply);
			});
		};
		self.everyActivatedIs = function (predicate) {
			return _.every(activatedNodes, predicate);
		};
		self.activateLevel = function (source, level) {
			const toActivate = _.map(
				_.filter(
					layoutModel.getLayout().nodes,
					function (node) {
						return node.level == level; //eslint-disable-line eqeqeq
					}
				),
				function (node) {
					return node.id;
				}
			);
			analytic('activateLevel', source);
			if (!_.isEmpty(toActivate)) {
				setActiveNodes(toActivate);
			}
		};
		self.reactivate = function (layout) {
			_.each(layout.nodes, function (node) {
				if (_.contains(activatedNodes, node.id)) {
					node.activated = true;
				}
			});
			return layout;
		};
	}());

	self.getNodeIdAtPosition = function (x, y) {
		const isPointOverNode = function (node) { //move to mapModel candidate
			/*jslint eqeq: true*/
				return x >= node.x &&
				y >= node.y &&
				x <= node.x + node.width &&
				y <= node.y + node.height;
			},
			node = _.find(layoutModel.getLayout().nodes, isPointOverNode);
		// QUESTION: Returns node.id, why not whole node?
		return node && node.id;
	};
	self.autoPosition = function (nodeId) {
		return idea.updateAttr(nodeId, 'position', false);
	};
	self.standardPositionNodeAt = function (nodeId, x, y, manualPosition) {
		let result = false;
		const rootNode = layoutModel.getNode(layoutModel.getNode(nodeId).rootId),
			getVerticallyClosestNode = function () {
				let verticallyClosestNode = {
					id: null,
					y: Infinity
				};
				_.each(idea.sameSideSiblingIds(nodeId), function (id) {
					// ISSUE: idea.sameSideSiblingIds(nodeId) can return deleted grouping (e.g. green, supporting) node, which means node is undefined in next line:
					// 	Trying check to fix
					const node = layoutModel.getNode(id);
					// Check node is not undefined:
					if (!node) {
						return false;
					}
					if (y < node.y && node.y < verticallyClosestNode.y) {
						verticallyClosestNode = node;
					}
				});
				return verticallyClosestNode;
			},
			parentIdea = idea.findParent(nodeId),
			parentNode = layoutModel.getNode(parentIdea.id),
			thisNode = layoutModel.getNode(nodeId),
			nodeBeingDragged = layoutModel.getNode(nodeId),
			tryFlip = function (rootNode, nodeBeingDragged, nodeDragEndX) {
				const flipRightToLeft = rootNode.x < nodeBeingDragged.x && nodeDragEndX < rootNode.x,
					flipLeftToRight = rootNode.x > nodeBeingDragged.x && rootNode.x < nodeDragEndX;
				if (flipRightToLeft || flipLeftToRight) {
					return idea.flip(nodeId);
				}
				return false;
			},
			validReposition = function () {
				return nodeBeingDragged.level <= 2 ||
					((nodeBeingDragged.x - parentNode.x) * (x - parentNode.x) > 0);
			},
			getMaxSequence = function () {
				if (_.isEmpty(parentIdea.ideas)) {
					return 0;
				}
				return _.max(_.map(parentIdea.ideas, function (i) {
					return (i.id !== nodeId && i.attr && i.attr.position && i.attr.position[2]) || 0;
				})) || 0;
			},
			manuallyPositionSubNode = function () {
				let xOffset;
				if (x < parentNode.x) {
					xOffset = parentNode.x - x - nodeBeingDragged.width + parentNode.width; /* negative nodes will get flipped so distance is not correct out of the box */
				} else {
					xOffset = x - parentNode.x;
				}
				analytic('nodeManuallyPositioned');
				return idea.updateAttr(
					nodeId,
					'position',
					[xOffset, y - parentNode.y, getMaxSequence() + 1]
				);
			},
			manuallyPositionRootNode = function () {
				return idea.updateAttr(
					nodeId,
					'position',
					[x, y, getMaxSequence() + 1]
				);
			};

		idea.startBatch();
		if (thisNode && thisNode.level === 2) {
			result = tryFlip(rootNode, nodeBeingDragged, x);
		}
		if (!manualPosition && validReposition()) {
			self.autoPosition(nodeId);
		}
		if (nodeBeingDragged.level > 1) {
			result = idea.positionBefore(nodeId, getVerticallyClosestNode().id) || result;
		}
		if (manualPosition && validReposition()) {
			if (nodeBeingDragged.level === 1) {
				result = manuallyPositionRootNode();
			} else {
				result = manuallyPositionSubNode() || result;
			}
		}
		setRootNodePositionsForPrecalculatedLayout(nodeId);
		idea.endBatch();
		return result;
	};
	self.topDownPositionNodeAt = function (nodeId, x, y, manualPosition) {
		let result, closestNodeToRight, closestNodeToLeft;
		const parentNode = idea.findParent(nodeId),
			nodeBeingDragged = layoutModel.getNode(nodeId),
			isRoot = function () {
				return nodeBeingDragged.level < 2;
			},
			manuallyPositionRootNode = function () {
				return idea.updateAttr(
					nodeId,
					'position',
					[x, y, 1]
				);
			};
		if (manualPosition) {
			if (isRoot()) {
				return manuallyPositionRootNode();
			} else {
				return idea.batch(function () {
					changeParent(nodeId, 'root');
					return manuallyPositionRootNode();
				});
			}
		}
		if (!parentNode) {
			return false;
		}
		_.each(parentNode.ideas, function (sibling) {
			const node = layoutModel.getNode(sibling.id);
			if (sibling.id === nodeId) {
				return;
			}
			if (x < node.x && (!closestNodeToRight || (Math.abs(x - node.x) < Math.abs(x - layoutModel.getNode(closestNodeToRight.id).x)))) {
				closestNodeToRight = sibling;
			}
			if (x > (node.x + node.width) && (!closestNodeToLeft || (Math.abs(x - node.x) < Math.abs(x - layoutModel.getNode(closestNodeToLeft.id).x)))) {
				closestNodeToLeft = sibling;
			}
		});
		idea.batch(function () {
			const useLeftNode = !!(closestNodeToRight && closestNodeToRight.id && idea.findChildRankById(closestNodeToRight.id) < 0),
				closestNode = useLeftNode ? closestNodeToLeft : closestNodeToRight,
				shouldFlip = (useLeftNode && (idea.findChildRankById(nodeId) > 0));
			self.autoPosition(nodeId);
			if (shouldFlip) {
				idea.flip(nodeId);
			}
			result = idea.positionBefore(nodeId, closestNode && closestNode.id);
		});
		return result;
	};
	self.positionNodeAt = function (nodeId, x, y, manualPosition) {
		if (layoutModel.getOrientation() === 'standard') {
			return self.standardPositionNodeAt(nodeId, x, y, manualPosition);
		} else {
			return self.topDownPositionNodeAt(nodeId, x, y, manualPosition);
		}
	};
	self.dropNode = function (nodeId, dropTargetId, shiftKey) {
		let clone;
		const parentIdea = idea.findParent(nodeId);
		if (dropTargetId === nodeId) {
			return false;
		}
		if (shiftKey) {
			clone = idea.clone(nodeId);
			if (clone) {
				idea.paste(dropTargetId, clone);
			}
			return false;
		}
		if (dropTargetId === parentIdea.id) {
			return self.autoPosition(nodeId);
		} else {
			return changeParent(nodeId, dropTargetId);
		}
	};
	self.setLayoutCalculator = function (newCalculator) {
		layoutCalculator = newCalculator;
	};
	self.setThemeSource = function (newThemeSource) {
		themeSource = newThemeSource;
	};
	self.dropImage = function (dataUrl, imgWidth, imgHeight, x, y, metaData) {
		const dropOn = function (ideaId, position) {
				const scaleX = Math.min(imgWidth, 300) / imgWidth,
					scaleY = Math.min(imgHeight, 300) / imgHeight,
					scale = Math.min(scaleX, scaleY),
					existing = idea.getAttrById(ideaId, 'icon');
				self.setIcon('drag and drop', dataUrl, Math.round(imgWidth * scale), Math.round(imgHeight * scale), (existing && existing.position) || position, ideaId, metaData);
			},
			addNew = function () {
				idea.startBatch();
				const newId = addSubIdea(currentlySelectedIdeaId);
				dropOn(newId, 'center');
				idea.endBatch();
				self.selectNode(newId);
			},
			nodeId = self.getNodeIdAtPosition(x, y);
		if (nodeId) {
			return dropOn(nodeId, 'left');
		}
		addNew();
	};
	self.setLabelGenerator = function (labelGenerator, labelGeneratorName) {
		currentLabelGenerator = labelGenerator;
		self.dispatchEvent('labelGeneratorChange', labelGeneratorName, !!labelGenerator);
		self.rebuildRequired();
	};
	self.getStandardReorderBoundary = function (nodeId) {
		const node = layoutModel.getNode(nodeId),
			nonRootStandardReorderBoundary = function (nodeId) {
				let opposite;
				const boundaries = [],
					node = layoutModel.getNode(nodeId),
					rootNode = layoutModel.getNode(node && node.rootId),
					isRightHalf = function (node, rootNode) {
						return node && rootNode && node.x >= rootNode.x;
					},
					parentIdea = idea.findParent(nodeId),
					parentNode = layoutModel.getNode(parentIdea.id),
					primaryEdge = isRightHalf(node, rootNode) ? 'left' : 'right',
					secondaryEdge = isRightHalf(node, rootNode) ? 'right' : 'left',
					siblingBoundary = function (siblings, side) {
						const tops = _.map(siblings, function (node) {
							// siblings sometimes contains initial undefined value, so this should stop an error being thrown
							//	 See https://workflowy.com/#/6c9851b2d1f5
							// TODO: Is undefined sibling sign of a bug?
								return node ? node.y : undefined;
							}),
							bottoms = _.map(siblings, function (node) {
								// siblings sometimes contains initial undefined value, so this should stop an error being thrown
								//	 See https://workflowy.com/#/6c9851b2d1f5
								// TODO: Is undefined sibling sign of a bug?
								return node ? node.y + node.height : undefined;
							}),
							result = {
								'minY': _.min(tops) - reorderMargin - node.height,
								'maxY': _.max(bottoms) + reorderMargin,
								'margin': reorderMargin
							};
						result.edge = side;
						if (side === 'left') {
							result.x = parentNode.x + parentNode.width + reorderMargin;
						} else {
							result.x = parentNode.x - reorderMargin;
						}
						return result;
					},
					parentBoundary = function (side) {
						const result = {
							'minY': parentNode.y - reorderMargin - node.height,
							'maxY': parentNode.y + parentNode.height + reorderMargin,
							'margin': reorderMargin
						};
						result.edge = side;
						if (side === 'left') {
							result.x = parentNode.x + parentNode.width + reorderMargin;
						} else {
							result.x = parentNode.x - reorderMargin;
						}

						return result;
					},
					sameSide = _.map(idea.sameSideSiblingIds(nodeId), function (id) {
						return layoutModel.getNode(id);
					}),
					otherSideSiblings = function () {
						let otherSide = _.map(parentIdea.ideas, function (subIdea) {
							return layoutModel.getNode(subIdea.id);
						});
						otherSide = _.without(otherSide, node);
						if (!_.isEmpty(sameSide)) {
							otherSide = _.difference(otherSide, sameSide);
						}
						return otherSide;
					};

				if (!_.isEmpty(sameSide)) {
					boundaries.push(siblingBoundary(sameSide, primaryEdge));
				}
				boundaries.push(parentBoundary(primaryEdge));
				if (node.level === 2) {
					opposite = otherSideSiblings();
					if (!_.isEmpty(opposite)) {
						boundaries.push(siblingBoundary(opposite, secondaryEdge));
					}
					boundaries.push(parentBoundary(secondaryEdge));
				}
				return boundaries;
			};
		if (node.level === 1) {
			return false;
		}
		return nonRootStandardReorderBoundary(nodeId);
	};

	self.getTopDownReorderBoundary = function (nodeId) {
		const node = layoutModel.getNode(nodeId),
			parentNode = idea.findParent(nodeId),
			tolerance = 10;
		let minX = Infinity, maxX = -Infinity, maxY = -Infinity,
			hasSiblings = false;
		if (!parentNode) {
			return [];
		}
		_.each(parentNode.ideas, function (subIdea) {
			const siblingNode = layoutModel.getNode(subIdea.id);

			if (siblingNode && subIdea.id !== nodeId) {
				hasSiblings = true;
				minX = Math.min(siblingNode.x, minX);
				maxX = Math.max(siblingNode.x + siblingNode.width, maxX);
				maxY = Math.max(siblingNode.y + siblingNode.height, maxY);
			}
		});
		if (!hasSiblings) {
			return [];
		}
		return ([{
			minY: node.y - node.height - tolerance,
			maxY: maxY + tolerance,
			minX: minX - node.width - tolerance,
			maxX: maxX + tolerance,
			edge: 'top'
		}]);
	};
	self.getReorderBoundary = function (nodeId) {

		if (layoutModel.getOrientation() === 'standard') {
			return self.getStandardReorderBoundary(nodeId);
		} else {
			return self.getTopDownReorderBoundary(nodeId);
		}
	};
	self.focusAndSelect = function (nodeId) {
		self.selectNode(nodeId);
		self.dispatchEvent('nodeFocusRequested', nodeId);
	};
	self.requestContextMenu = function (eventPointX, eventPointY) {
		if (isInputEnabled && isEditingEnabled) {
			self.dispatchEvent('contextMenuRequested', currentlySelectedIdeaId, eventPointX, eventPointY);
			return true;
		}
		return false;
	};
	// self.setTheme = function (themeId) {
	// 	if (!isEditingEnabled) {
	// 		return false;
	// 	}
	// 	const themeObj = themeSource && themeSource(themeId);
	// 	autoThemedIdeaUtils.themeChanged(idea, themeObj, themeId);
	// };
	self.makeSelectedNodeRoot = function () {
		const nodeId = self.getSelectedNodeId();
		if (!nodeId || idea.isRootNode(nodeId)) {
			return false;
		}
		if (isInputEnabled && isEditingEnabled) {
			return idea.batch(function () {
				setRootNodePositionsForPrecalculatedLayout(nodeId, layoutModel.getLayout());
				const result = changeParent(nodeId, 'root');
				setNodePositionFromCurrentLayout(nodeId);
				setRootNodePositionsForPrecalculatedLayout(nodeId);
				return result;
			});
		}
	};
	self.setNodeWidth = function (source, id, width) {
		idea.mergeAttrProperty(id, 'style', 'width', width);
	};
	self.unsetSelectedNodeWidth = function (source) {
		if (!isEditingEnabled) {
			return false;
		}
		analytic('unsetSelectedNodeWidth', source);
		self.applyToActivated(function (id) {
			idea.mergeAttrProperty(id, 'style', 'width', false);
		});
	};
	self.unsetSelectedNodePosition = function (source) {
		if (!isEditingEnabled) {
			return false;
		}
		analytic('unsetSelectedNodePosition', source);
		self.applyToActivated(self.autoPosition);
	};
	self.insertRoot = function (source, initialTitle) {
		const createNode = function () {
			if (initialTitle) {
				return addSubIdea(idea.id, initialTitle);
			} else {
				return addSubIdea(idea.id);
			}
		};
		if (!isEditingEnabled) {
			return false;
		}
		analytic('addRootNode', source);
		if (isInputEnabled) {
			let newId = false;
			idea.batch(function () {
				newId = createNode();
				positionNextTo(newId, self.getSelectedNodeId());
				setRootNodePositionsForPrecalculatedLayout(newId);
			});
			if (newId) {
				if (initialTitle) {
					selectNewIdea(newId);
				} else {
					editNewIdea(newId);
				}
			}
		}
	};
	self.lineLabelClicked = function (line) {
		self.dispatchEvent('lineLabelClicked', line);
	};
};
