/*global require, module*/
const jQuery = require('jquery'),
	_ = require('underscore'),
	calculateLayout = require('../core/layout/calculate-layout'),
	nodeCacheMark = require('./node-cache-mark');

require('./create-node');
require('./hammer-draggable');
require('./node-resize-widget');
require('./update-connector');
require('./update-link');
require('./node-with-id');
require('./update-node-content');
require('./update-stage');
require('./queue-fade-out');
require('./edit-node');
require('./update-reorder-bounds');
require('./create-connector');
require('./create-link');
require('./find-line');
require('./create-reorder-bounds');




module.exports = function DomMapController(mapModel, stageElement, touchEnabled, resourceTranslator, themeSource, options) {
	'use strict';
	let stageMargin = (options && options.stageMargin),
		stageVisibilityMargin = (options && options.stageVisibilityMargin),
		currentDroppable = false,
		stats = {},
		viewPortDimensions;

	const self = this,
		viewPort = stageElement.parent(),
		viewPortAnimOptions = {duration: 400},
		reorderBounds = mapModel.isEditingEnabled() ? stageElement.createReorderBounds() : jQuery('<div>'),
		svgPixel = 'data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" width="1" height="1"></svg>',
		dummyTextBox = jQuery('<div>').addClass('mapjs-node').addClass('noTransition').css({position: 'absolute', visibility: 'hidden'}),
		getViewPortDimensions = function () {
			if (viewPortDimensions) {
				return viewPortDimensions;
			}
			viewPortDimensions =  {
				left: viewPort.scrollLeft(),
				top: viewPort.scrollTop(),
				innerWidth: viewPort.innerWidth(),
				innerHeight: viewPort.innerHeight()
			};
			return viewPortDimensions;
		},
		stageToViewCoordinates = function (x, y) {
			const stage = stageElement.data(),
				scrollPosition = getViewPortDimensions();
			return {
				x: stage.scale * (x + stage.offsetX) - scrollPosition.left,
				y: stage.scale * (y + stage.offsetY) - scrollPosition.top
			};
		},
		viewToStageCoordinates = function (x, y) {
			const stage = stageElement.data(),
				scrollPosition = getViewPortDimensions();
			return {
				x: (scrollPosition.left + x) / stage.scale - stage.offsetX,
				y: (scrollPosition.top + y) / stage.scale - stage.offsetY
			};
		},
		updateScreenCoordinates = function () {
			const element = jQuery(this);
			element.css({
				'left': element.data('x'),
				'top': element.data('y')
			}).trigger('mapjs:move');
		},
		ensureSpaceForPoint = function (x, y) {/* in stage coordinates */
			const stage = stageElement.data();
			let dirty = false;
			if (x < -1 * stage.offsetX) {
				stage.width =  stage.width - stage.offsetX - x;
				stage.offsetX = -1 * x;
				dirty = true;
			}
			if (y < -1 * stage.offsetY) {
				stage.height = stage.height - stage.offsetY - y;
				stage.offsetY = -1 * y;
				dirty = true;
			}
			if (x > stage.width - stage.offsetX) {
				stage.width = stage.offsetX + x;
				dirty = true;
			}
			if (y > stage.height - stage.offsetY) {
				stage.height = stage.offsetY + y;
				dirty = true;
			}
			if (dirty) {
				stageElement.updateStage();
			}
		},
		ensureSpaceForNode = function () {
			return jQuery(this).each(function () {
				const node = jQuery(this).data(),
					margin = stageMargin || {top: 0, left: 0, bottom: 0, right: 0};
				/* sequence of calculations is important because maxX and maxY take into consideration the new offsetX snd offsetY */
				ensureSpaceForPoint(node.x - margin.left, node.y - margin.top);
				ensureSpaceForPoint(node.x + node.width + margin.right, node.y + node.height + margin.bottom);
			});
		},
		centerViewOn = function (x, y, animate) { /*in the stage coordinate system*/
			const stage = stageElement.data(),
				viewPortCenter = {
					x: Math.round(viewPort.innerWidth() / 2),
					y: Math.round(viewPort.innerHeight() / 2)
				},
				margin = stageVisibilityMargin || {top: 0, left: 0, bottom: 0, right: 0};
			let newLeftScroll = false, newTopScroll = false;

			ensureSpaceForPoint(x - viewPortCenter.x / stage.scale, y - viewPortCenter.y / stage.scale);
			ensureSpaceForPoint(x + viewPortCenter.x / stage.scale - margin.left, y + viewPortCenter.y / stage.scale - margin.top);

			newLeftScroll = stage.scale * (x + stage.offsetX) - viewPortCenter.x;
			newTopScroll = stage.scale * (y + stage.offsetY) - viewPortCenter.y;
			viewPort.finish();
			if (animate) {
				viewPort.animate({
					scrollLeft: newLeftScroll,
					scrollTop: newTopScroll
				}, viewPortAnimOptions);
			} else {
				viewPort.scrollLeft(newLeftScroll);
				viewPort.scrollTop(newTopScroll);
			}
		},
		centerViewOnNode = function (ideaId, animate) {
			const node = stageElement.nodeWithId(ideaId).data(),
				nodeCenterX = Math.round(node.x + node.width / 2),
				nodeCenterY = Math.round(node.y + node.height / 2);
			centerViewOn(nodeCenterX, nodeCenterY, animate);
		},
		stagePointAtViewportCenter = function () {
			return viewToStageCoordinates(Math.round(viewPort.innerWidth() / 2), Math.round(viewPort.innerHeight() / 2));
		},
		ensureNodeVisible = function (domElement) {
			if (!domElement || domElement.length === 0) {
				return;
			}
			viewPort.finish();
			const node = domElement.data(),
				nodeTopLeft = stageToViewCoordinates(node.x, node.y),
				nodeBottomRight = stageToViewCoordinates(node.x + node.width, node.y + node.height),
				animation = {},
				margin = stageVisibilityMargin || {top: 10, left: 10, bottom: 10, right: 10};
			if ((nodeTopLeft.x - margin.left) < 0) {
				animation.scrollLeft = viewPort.scrollLeft() + nodeTopLeft.x - margin.left;
			} else if ((nodeBottomRight.x + margin.right) > viewPort.innerWidth()) {
				animation.scrollLeft = viewPort.scrollLeft() + nodeBottomRight.x - viewPort.innerWidth() + margin.right;
			}
			if ((nodeTopLeft.y - margin.top) < 0) {
				animation.scrollTop = viewPort.scrollTop() + nodeTopLeft.y - margin.top;
			} else if ((nodeBottomRight.y + margin.bottom) > viewPort.innerHeight()) {
				animation.scrollTop = viewPort.scrollTop() + nodeBottomRight.y - viewPort.innerHeight() + margin.bottom;
			}
			if (!_.isEmpty(animation)) {
				viewPort.animate(animation, viewPortAnimOptions);
			}
		},
		viewportCoordinatesForPointEvent = function (evt) {
			const dropPosition = (evt && evt.gesture && evt.gesture.center) || evt,
				vpOffset = viewPort.offset();
			let result;
			if (dropPosition) {
				result = {
					x: dropPosition.pageX - vpOffset.left,
					y: dropPosition.pageY -  vpOffset.top
				};
				if (result.x >= 0 && result.x <= viewPort.innerWidth() && result.y >= 0 && result.y <= viewPort.innerHeight()) {
					return result;
				}
			}
		},
		stagePositionForPointEvent = function (evt) {
			const viewportDropCoordinates = viewportCoordinatesForPointEvent(evt);
			if (viewportDropCoordinates) {
				return viewToStageCoordinates(viewportDropCoordinates.x, viewportDropCoordinates.y);
			}
		},
		clearCurrentDroppable = function () {
			if (currentDroppable || currentDroppable === false) {
				jQuery('.mapjs-node').removeClass('droppable');
				currentDroppable = undefined;
			}
		},
		showDroppable = function (nodeId) {
			stageElement.nodeWithId(nodeId).addClass('droppable');
			currentDroppable = nodeId;
		},
		withinReorderBoundary = function (boundaries, box) {
			const closeTo = function (reorderBoundary) {
				let nodeX = box.x;
				if (reorderBoundary.edge === 'right') {
					nodeX += box.width;
				}
				if (reorderBoundary.x && reorderBoundary.margin) {
					return Math.abs(nodeX - reorderBoundary.x) < reorderBoundary.margin * 2 &&
						box.y < reorderBoundary.maxY &&
						box.y > reorderBoundary.minY;
				} else {
					return box.y < reorderBoundary.maxY &&
						box.y > reorderBoundary.minY &&
						box.x < reorderBoundary.maxX &&
						box.x > reorderBoundary.minX;
				}
			};
			if (_.isEmpty(boundaries)) {
				return false;
			}
			if (!box) {
				return false;
			}
			return _.find(boundaries, closeTo);
		},
		translateToPixel = function () {
			return svgPixel;
		},
		record = function (evt) {
			if (!stats) {
				return false;
			}
			if (!stats[evt]) {
				stats[evt] = 0;
			}
			stats[evt] = stats[evt] + 1;
		},
		recordCacheMiss = function (actual, expected) {
			if (!stats) {
				return false;
			}
			if (!stats.cacheMisses) {
				stats.cacheMisses = [];
			}
			stats.cacheMisses.push({old: actual, new: expected});
		};
	self.resetStats = function () {
		stats = {};
	};

	self.getStats = function () {
		return stats;
	};
	self.setStageMargin = function (newMargins) {
		stageMargin = newMargins;
	};
	self.setStageVisibilityMargin = function (newMargins) {
		stageVisibilityMargin = newMargins;
	};


	self.dimensionProvider = function (idea, level) {
		let result = false,
			textBox = stageElement.nodeWithId(idea.id);
		const expectedCacheMark = nodeCacheMark(idea, {level: level, theme: themeSource()});
		if (textBox && textBox.length > 0) {
			if (_.isEqual(textBox.data('nodeCacheMark'), expectedCacheMark)) {
				record('dimension-cache:hit');
				return _.pick(textBox.data(), 'width', 'height', 'textWidth');
			}
		}
		record('dimension-cache:miss');
		recordCacheMiss(textBox.data('nodeCacheMark'), expectedCacheMark);
		textBox = dummyTextBox;
		textBox.appendTo('body').updateNodeContent(
			idea,
			themeSource(),
			{resourceTranslator: translateToPixel, level: level, decorations: ['left', 'right']}
		);
		result = {
			width: Math.ceil(textBox.outerWidth(true)),
			textWidth: Math.ceil(textBox.find('[data-mapjs-role="title"]').outerWidth(true)),
			height: Math.ceil(textBox.outerHeight(true))
		};
		textBox.detach();
		return result;
	};

	mapModel.setLayoutCalculator(function (contentAggregate, contextNode) {
		return calculateLayout(contentAggregate, self.dimensionProvider, {contextNode: contextNode, theme: themeSource()});
	});

	viewPort.on('scroll', function () {
		viewPortDimensions = undefined;
	});
	mapModel.addEventListener('nodeCreated', function (node) {
		let currentReorderBoundary;
		const element = stageElement.createNode(node)
			.updateNodeContent(node, themeSource(), {resourceTranslator: resourceTranslator})
			.nodeResizeWidget(node.id, mapModel, stagePositionForPointEvent)
			.on('tap', function (evt) {

				const realEvent = (evt.gesture && evt.gesture.srcEvent) || evt;
				if (realEvent.button && realEvent.button !== -1) {
					return;
				}
				mapModel.clickNode(node.id, realEvent);
				if (evt) {
					evt.stopPropagation();
				}
				if (evt && evt.gesture) {
					evt.gesture.stopPropagation();
				}

			})
			.on('doubletap', function (event) {
				if (event) {
					event.stopPropagation();
					if (event.gesture) {
						event.gesture.stopPropagation();
					}
				}
				if (!mapModel.isEditingEnabled()) {
					mapModel.toggleCollapse('mouse');
					return;
				}
				mapModel.editNode('mouse');
			})
			.on('attachment-click', function () {
				mapModel.openAttachment('mouse', node.id);
			})
			.on('decoration-click', function (evt, decorationType) {
				mapModel.decorationAction('mouse', node.id, decorationType);
			})
			.each(ensureSpaceForNode)
			.each(updateScreenCoordinates)
			.on('mm:start-dragging mm:start-dragging-shadow', function (evt) {
				if (evt && evt.relatedTarget === this) {
					mapModel.selectNode(node.id);
					currentReorderBoundary = mapModel.getReorderBoundary(node.id);
					element.addClass('dragging');
				}
			})
			.on('mm:drag', function (evt) {
				const dropCoords = stagePositionForPointEvent(evt),
					currentPosition = evt.currentPosition && stagePositionForPointEvent({pageX: evt.currentPosition.left, pageY: evt.currentPosition.top}),
					hasShift = evt && evt.gesture && evt.gesture.srcEvent && evt.gesture.srcEvent.shiftKey,
					nodeId = dropCoords && mapModel.getNodeIdAtPosition(dropCoords.x, dropCoords.y);
				let border;
				if (!dropCoords) {
					clearCurrentDroppable();
					return;
				}


				if (!hasShift && !nodeId && currentPosition) {
					currentPosition.width = element.outerWidth();
					currentPosition.height = element.outerHeight();
					border = withinReorderBoundary(currentReorderBoundary, currentPosition);
					reorderBounds.updateReorderBounds(border, currentPosition, dropCoords);
				} else {
					reorderBounds.hide();
				}
				if (!nodeId || nodeId === node.id) {
					clearCurrentDroppable();
				} else if (nodeId !== currentDroppable) {
					clearCurrentDroppable();
					if (nodeId) {
						showDroppable(nodeId);
					}
				}
			})
			.on('contextmenu', function (event) {
				mapModel.selectNode(node.id);
				if (mapModel.requestContextMenu(event.pageX, event.pageY)) {
					event.preventDefault();
					return false;
				}
			})
			.on('mm:stop-dragging', function (evt) {
				element.removeClass('dragging');
				reorderBounds.hide();
				let dropResult, manualPosition;
				const isShift = evt && evt.gesture && evt.gesture.srcEvent && evt.gesture.srcEvent.shiftKey,
					stageDropCoordinates = stagePositionForPointEvent(evt),
					nodeAtDrop = stageDropCoordinates && mapModel.getNodeIdAtPosition(stageDropCoordinates.x, stageDropCoordinates.y),
					finalPosition = evt.finalPosition && stagePositionForPointEvent({pageX: evt.finalPosition.left, pageY: evt.finalPosition.top});

				clearCurrentDroppable();
				if (!stageDropCoordinates) {
					return;
				}

				if (nodeAtDrop && nodeAtDrop !== node.id) {
					dropResult = mapModel.dropNode(node.id, nodeAtDrop, !!isShift);
				} else {
					finalPosition.width = element.outerWidth();
					finalPosition.height = element.outerHeight();
					manualPosition = (!!isShift) || !withinReorderBoundary(currentReorderBoundary, finalPosition);
					if (manualPosition) {
						dropResult = mapModel.positionNodeAt(node.id, finalPosition.x, finalPosition.y, manualPosition);
					} else {
						dropResult = mapModel.positionNodeAt(node.id, stageDropCoordinates.x, stageDropCoordinates.y, manualPosition);
					}
				}
				return dropResult;
			})
			.on('mm:cancel-dragging', function () {
				clearCurrentDroppable();
				element.removeClass('dragging');
				reorderBounds.hide();
			}).on('mm:resize', function (event) {
				mapModel.setNodeWidth('mouse', node.id, event.nodeWidth);
			});
		if (touchEnabled) {
			element.on('hold', function (evt) {
				const realEvent = (evt.gesture && evt.gesture.srcEvent) || evt;
				mapModel.clickNode(node.id, realEvent);
				if (mapModel.requestContextMenu(evt.gesture.center.pageX, evt.gesture.center.pageY)) {
					evt.preventDefault();
					if (evt.gesture) {
						evt.gesture.preventDefault();
						evt.gesture.stopPropagation();
					}
					return false;
				}
			});
		}
		element.css('min-width', element.css('width'));
		if (mapModel.isEditingEnabled()) {
			element.shadowDraggable();
		}
	});
	mapModel.addEventListener('nodeSelectionChanged', function (ideaId, isSelected) {
		const node = stageElement.nodeWithId(ideaId);
		if (isSelected) {
			node.addClass('selected');
			ensureNodeVisible(node);
		} else {
			node.removeClass('selected');
		}
	});
	mapModel.addEventListener('nodeRemoved', function (node) {
		stageElement.nodeWithId(node.id).queueFadeOut(themeSource());
	});
	mapModel.addEventListener('nodeMoved', function (node /*, reason*/) {
		stageElement.nodeWithId(node.id).data({
			'x': Math.round(node.x),
			'y': Math.round(node.y),
			'width': Math.round(node.width),
			'height': Math.round(node.height)
		}).each(ensureSpaceForNode).each(updateScreenCoordinates);
	});
	mapModel.addEventListener('nodeTitleChanged nodeAttrChanged nodeLabelChanged', function (n) {
		stageElement.nodeWithId(n.id).updateNodeContent(n, themeSource(), { resourceTranslator: resourceTranslator}).each(ensureSpaceForNode);
	});
	mapModel.addEventListener('connectorMoved', function (connector /*, reason*/) {
		stageElement.findLine(connector).updateConnector({theme: themeSource()});
	});
	mapModel.addEventListener('connectorCreated', function (connector) {
		const connectorOptions = {theme: themeSource()},
			element = stageElement.find('[data-mapjs-role=svg-container]')
			.createConnector(connector, connectorOptions)
			.updateConnector(connectorOptions);
		stageElement.nodeWithId(connector.from).add(stageElement.nodeWithId(connector.to))
			.on('mapjs:resize', function () {
				element.updateConnector({theme: themeSource()});
			});
		element.on('tap', function (event) {
			const theme = themeSource();
			if (!theme || !theme.connectorEditingContext || (theme.connectorEditingContext.allowed && theme.connectorEditingContext.allowed.length)) {
				if (event.target && event.target.tagName === 'text') {
					mapModel.lineLabelClicked(connector);
				} else 	{
					mapModel.selectConnector('mouse', connector,
						event && event.gesture && event.gesture.center &&
							{ x: event.gesture.center.pageX, y: event.gesture.center.pageY }
					);
				}
			}
			event.gesture && event.gesture.stopPropagation && event.gesture.stopPropagation();
			event.stopPropagation();
		});
	});
	mapModel.addEventListener('connectorRemoved', function (connector) {
		stageElement.findLine(connector).queueFadeOut(themeSource());
	});
	mapModel.addEventListener('linkCreated', function (line) {
		const link = stageElement
			.find('[data-mapjs-role=svg-container]')
			.createLink(line, {theme: themeSource()}).updateLink({theme: themeSource()});
		link.on('tap', function (event) {
			if (event.target && event.target.tagName === 'text') {
				mapModel.lineLabelClicked(line);
			} else {
				mapModel.selectLink('mouse', line, { x: event.gesture.center.pageX, y: event.gesture.center.pageY });
			}
			event.stopPropagation();
			event.gesture.stopPropagation();
		});
		stageElement.nodeWithId(line.ideaIdFrom).add(stageElement.nodeWithId(line.ideaIdTo))
			.on('mapjs:move mm:drag mapjs:resize', function () {
				link.updateLink({theme: themeSource()});
			});
	});
	mapModel.addEventListener('linkRemoved', function (l) {
		stageElement.findLine(l).queueFadeOut(themeSource());
	});
	mapModel.addEventListener('mapScaleChanged', function (scaleMultiplier /*, zoomPoint */) {
		const currentScale = stageElement.data('scale'),
			targetScale = Math.max(Math.min(currentScale * scaleMultiplier, 5), 0.2),
			currentCenter = stagePointAtViewportCenter();
		if (currentScale === targetScale) {
			return;
		}
		stageElement.data('scale', targetScale).updateStage();
		centerViewOn(currentCenter.x, currentCenter.y);
	});


	mapModel.addEventListener('nodeVisibilityRequested', function (ideaId) {
		const id = ideaId || mapModel.getCurrentlySelectedIdeaId(),
			node = stageElement.nodeWithId(id);
		if (node) {
			ensureNodeVisible(node);
		}

	});
	mapModel.addEventListener('nodeFocusRequested', function (ideaId) {
		if (stageElement.data('scale') !== 1) {
			stageElement.data('scale', 1).updateStage();
		}
		centerViewOnNode(ideaId, true);
	});
	mapModel.addEventListener('mapViewResetRequested', function () {
		stageElement.data({'scale': 1, 'height': 0, 'width': 0, 'offsetX': 0, 'offsetY': 0}).updateStage();
		jQuery(stageElement).find('.mapjs-node').each(ensureSpaceForNode);
		jQuery(stageElement).find('[data-mapjs-role=connector]').updateConnector({theme: themeSource()});
		jQuery(stageElement).find('[data-mapjs-role=link]').updateLink({theme: themeSource()});
		centerViewOnNode(mapModel.getCurrentlySelectedIdeaId());
		viewPort.focus();
	});
	mapModel.addEventListener('layoutChangeStarting', function () {
		viewPortDimensions = undefined;
	});
	mapModel.addEventListener('layoutChangeComplete', function (/*layoutChangeOptions*/) {
		ensureNodeVisible(stageElement.nodeWithId(mapModel.getCurrentlySelectedIdeaId()));
	});

	/* editing */
	if (!options || !options.inlineEditingDisabled) {
		mapModel.addEventListener('nodeEditRequested', function (nodeId, shouldSelectAll, editingNew) {
			const editingElement = stageElement.nodeWithId(nodeId);
			mapModel.setInputEnabled(false);
			viewPort.finish(); /* close any pending scroll animations */
			editingElement.editNode(shouldSelectAll)
			.then(function (newText) {
				mapModel.setInputEnabled(true);
				mapModel.updateTitle(nodeId, newText, editingNew);
				editingElement.focus();
			})
			.catch(function () {
				mapModel.setInputEnabled(true);
				// We don't cancel creation upon cancelling edit of new node
				// if (editingNew) {
				// 	mapModel.undo('internal');
				// }
				mapModel.updateTitle(nodeId, editingElement.data('title'), editingNew);
				editingElement.focus();
			});
		});
	}
	mapModel.addEventListener('linkAttrChanged', function (l) {
		stageElement.findLine(l).data('attr', (l.attr && l.attr.style) || {}).updateLink({theme: themeSource()});
	});
	mapModel.addEventListener('connectorAttrChanged', function (connector) {
		stageElement.findLine(connector).data('attr', connector.attr || false).updateConnector({theme: themeSource()});
	});
	mapModel.addEventListener('activatedNodesChanged', function (activatedNodes, deactivatedNodes) {
		_.each(activatedNodes, function (nodeId) {
			stageElement.nodeWithId(nodeId).addClass('activated');
		});
		_.each(deactivatedNodes, function (nodeId) {
			stageElement.nodeWithId(nodeId).removeClass('activated');
		});
	});
	['nodeTitleChanged', 'nodeAttrChanged', 'nodeLabelChanged', 'nodeMoved', 'nodeRemoved', 'nodeCreated', 'connectorCreated', 'connectorRemoved', 'linkCreated', 'linkRemoved', 'linkAttrChanged', 'connectorAttrChanged'].forEach(evt => {
		mapModel.addEventListener(evt, () => {
			record(evt);
		});
	});
};

