/*jshint loopfunc:true */
/*global module, require*/
const _ = require('underscore'),
	observable = require('../util/observable'),
	contentUpgrade = require('./content-upgrade');
module.exports = function content(contentAggregate, initialSessionId) {
	'use strict';
	let cachedId,
		sessionKey = initialSessionId,
		configuration = {},
		isRedoInProgress = false;


	const invalidateIdCache = function () {
		cachedId = undefined;
	},
		maxId = function maxId(idea) {
			idea = idea || contentAggregate;
			if (!idea.ideas) {
				return parseInt(idea.id, 10) || 0;
			}
			return _.reduce(
				idea.ideas,
				function (result, subidea) {
					return Math.max(result, maxId(subidea));
				},
				parseInt(idea.id, 10) || 0
			);
		},
		nextId = function nextId(originSession) {
			originSession = originSession || sessionKey;
			if (!cachedId) {
				cachedId = maxId();
			}
			cachedId += 1;
			if (originSession) {
				return cachedId + '.' + originSession;
			}
			return cachedId;
		},
		init = function (contentIdea, originSession) {
			const initOfRoot = contentIdea.id === contentAggregate.id;
			if (!contentIdea.id) {
				contentIdea.id = nextId(originSession);
			} else {
				invalidateIdCache();
			}
			if (contentIdea.ideas) {
				_.each(contentIdea.ideas, function (value, key) {
					if (!initOfRoot && value.attr && value.attr.group && _.isEmpty(value.ideas)) {
						delete contentIdea.ideas[key];
					} else {
						contentIdea.ideas[parseFloat(key)] = init(value, originSession);
					}

				});
			}
			if (!contentIdea.title) {
				contentIdea.title = '';
			}
			contentIdea.containsDirectChild = contentIdea.findChildRankById = function (childIdeaId) {
				return parseFloat(
					_.reduce(
						contentIdea.ideas,
						function (res, value, key) {
							return value.id == childIdeaId ? key : res; //eslint-disable-line eqeqeq
						},
						undefined
					)
				);
			};
			contentIdea.findSubIdeaById = function (childIdeaId) {
				const myChild = _.find(contentIdea.ideas, function (idea) {
					return idea.id == childIdeaId; //eslint-disable-line eqeqeq
				});
				return myChild || _.reduce(contentIdea.ideas, function (result, idea) {
					return result || idea.findSubIdeaById(childIdeaId);
				}, undefined);
			};
			contentIdea.isEmptyGroup = function () {
				return !contentAggregate.isRootNode(contentIdea.id) && contentIdea.attr && contentIdea.attr.group && _.isEmpty(contentIdea.ideas);
			};
			contentIdea.find = function (predicate) {
				const current = predicate(contentIdea) ? [_.pick(contentIdea, 'id', 'title')] : [];
				if (_.size(contentIdea.ideas) === 0) {
					return current;
				}
				return _.reduce(contentIdea.ideas, function (result, idea) {
					return _.union(result, idea.find(predicate));
				}, current);
			};
			contentIdea.getAttr = function (name) {
				if (contentIdea.attr && contentIdea.attr[name]) {
					return _.clone(contentIdea.attr[name]);
				}
				return false;
			};
			contentIdea.sortedSubIdeas = function () {
				const result = [],
					childKeys = contentIdea.ideas && _.groupBy(_.map(_.keys(contentIdea.ideas), parseFloat), function (key) {
						return key > 0;
					}),
					sortedChildKeys = childKeys && _.sortBy(childKeys[true], Math.abs).concat(_.sortBy(childKeys[false], Math.abs)); //eslint-disable-line dot-notation

				if (!contentIdea.ideas) {
					return [];
				}

				_.each(sortedChildKeys, function (key) {
					result.push(contentIdea.ideas[key]);
				});
				return result;
			};
			contentIdea.traverse = function (iterator, postOrder) {
				if (!postOrder && contentIdea !== contentAggregate) {
					iterator(contentIdea);
				}
				_.each(contentIdea.sortedSubIdeas(), function (subIdea) {
					subIdea.traverse(iterator, postOrder);
				});
				if (postOrder && contentIdea !== contentAggregate) {
					iterator(contentIdea);
				}
			};
			return contentIdea;
		},
		maxKey = function (kvMap, sign) {
			let currentKeys = [];
			sign = sign || 1;
			if (_.size(kvMap) === 0) {
				return 0;
			}
			currentKeys = _.keys(kvMap);
			currentKeys.push(0); /* ensure at least 0 is there for negative ranks */
			return _.max(_.map(currentKeys, parseFloat), function (x) {
				return x * sign;
			});
		},
		isRootNode = function (id) {
			return !!_.find(contentAggregate.ideas, function (idea) {
				return idea.id === id;
			});
		},
		nextChildRank = function (parentIdea) {
			let newRank = 0, counts = 0, childRankSign = 1;
			if (isRootNode(parentIdea.id)) {
				counts = _.countBy(parentIdea.ideas, function (v, k) {
					return k < 0;
				});
				if ((counts['true'] || 0) < counts['false']) { //eslint-disable-line dot-notation
					childRankSign = -1;
				}
			}
			if (parentIdea.ideas.length == 0) { // This ensures that rank of empty arrays is always 0, which means index starts correctly with new children.
				newRank = 0
			} else {
				newRank = maxKey(parentIdea.ideas, childRankSign) + childRankSign;
			}
			return newRank;
		},
		appendSubIdea = function (parentIdea, subIdea) {
			let rank = 0;
			parentIdea.ideas = parentIdea.ideas || {};
			rank = nextChildRank(parentIdea);
			parentIdea.ideas[rank] = subIdea;
			return rank;
		},
		findIdeaById = function (ideaId) {
			return contentAggregate.id == ideaId ? contentAggregate : contentAggregate.findSubIdeaById(ideaId); //eslint-disable-line eqeqeq
		},
		sameSideSiblingRanks = function (parentIdea, ideaRank) {
			return _.reject((_.map(_.keys(parentIdea.ideas), parseFloat)), function (k) {
				return k * ideaRank < 0;
			});
		},
		sign = function (number) {
			/* intentionally not returning 0 case, to help with split sorting into 2 groups */
			return number < 0 ? -1 : 1;
		},
		eventStacks = {},
		redoStacks = {},

		batches = {},
		notifyChange = function (method, args, originSession) {
			if (originSession) {
				contentAggregate.dispatchEvent('changed', method, args, originSession);
			} else {
				contentAggregate.dispatchEvent('changed', method, args);
			}
		},
		logChange = function (method, args, undofunc, originSession) {
			const event = { eventMethod: method, eventArgs: args, undoFunction: undofunc };
			if (batches[originSession]) {
				batches[originSession].push(event);
				return;
			}
			if (!eventStacks[originSession]) {
				eventStacks[originSession] = [];
			}
			eventStacks[originSession].push(event);

			if (isRedoInProgress) {
				contentAggregate.dispatchEvent('changed', 'redo', undefined, originSession);
			} else {
				notifyChange(method, args, originSession);
				redoStacks[originSession] = [];
			}
		},
		appendChange = function (method, args, undofunc, originSession) {
			const executeOutsideBatch = function () {
				const prev = eventStacks[originSession].pop();
				if (prev.eventMethod === 'batch') {
					eventStacks[originSession].push({
						eventMethod: 'batch',
						eventArgs: prev.eventArgs.concat([[method].concat(args)]),
						undoFunction: function () {
							undofunc();
							prev.undoFunction();
						}
					});
				} else {
					eventStacks[originSession].push({
						eventMethod: 'batch',
						eventArgs: [[prev.eventMethod].concat(prev.eventArgs)].concat([[method].concat(args)]),
						undoFunction: function () {
							undofunc();
							prev.undoFunction();
						}
					});
				}
				if (isRedoInProgress) {
					contentAggregate.dispatchEvent('changed', 'redo', undefined, originSession);
				} else {
					notifyChange(method, args, originSession);
					redoStacks[originSession] = [];
				}
			};

			if (method === 'batch' || batches[originSession] || !eventStacks || !eventStacks[originSession] || eventStacks[originSession].length === 0) {
				logChange(method, args, undofunc, originSession);
				return;
			} else {
				executeOutsideBatch();
			}
		},
		reorderChild = function (parentIdea, newRank, oldRank) {
			const undoFunction = function () {
				if (parentIdea.ideas[oldRank] || !parentIdea.ideas[newRank]) {
					return false;
				}
				parentIdea.ideas[oldRank] = parentIdea.ideas[newRank];
				delete parentIdea.ideas[newRank];
			};
			parentIdea.ideas[newRank] = parentIdea.ideas[oldRank];
			delete parentIdea.ideas[oldRank];
			return undoFunction;
		},
		sessionFromId = function (id) {
			const dotIndex = String(id).indexOf('.');
			return dotIndex > 0 && id.substr(dotIndex + 1);
		},
		commandProcessors = {},

		uniqueResourcePostfix = '/xxxxxxxx-yxxx-yxxx-yxxx-xxxxxxxxxxxx/'.replace(/[xy]/g, function (c) {
			const r = Math.random() * 16 | 0, v = c === 'x' ? r : (r & 0x3 | 0x8);
			return v.toString(16);
		}) + (sessionKey || ''),
		updateAttr = function (object, attrName, attrValue) {
			const oldAttr = object && _.extend({}, object.attr);
			if (!object) {
				return false;
			}
			object.attr = _.extend({}, object.attr);
			if (!attrValue || attrValue === 'false' || (_.isObject(attrValue) && _.isEmpty(attrValue))) {
				if (!object.attr[attrName]) {
					return false;
				}
				delete object.attr[attrName];
			} else {
				if (_.isEqual(object.attr[attrName], attrValue)) {
					return false;
				}
				object.attr[attrName] = JSON.parse(JSON.stringify(attrValue));
			}
			if (_.size(object.attr) === 0) {
				delete object.attr;
			}
			return function () {
				object.attr = oldAttr;
			};
		},
		findLinkBetween = function (ideaIdFrom, ideaIdTo) {
			return _.find(
				contentAggregate.links,
				function (link) {
					return (link.ideaIdFrom === ideaIdFrom && link.ideaIdTo === ideaIdTo) || (link.ideaIdFrom === ideaIdTo && link.ideaIdTo === ideaIdFrom);
				});
		},
		isLinkValid = function (ideaIdFrom, ideaIdTo) {
			const ideaFrom = findIdeaById(ideaIdFrom),
				ideaTo = findIdeaById(ideaIdTo),
				isParentChild = ideaFrom && ideaTo && (
					_.find(ideaFrom.ideas, function (node) {
						return node.id === ideaIdTo;
					}) ||
					_.find(ideaTo.ideas, function (node) {
						return node.id === ideaIdFrom;
					})
				);

			if (ideaIdFrom === ideaIdTo) {
				return false;
			}
			if (!ideaFrom) {
				return false;
			}
			if (!ideaTo) {
				return false;
			}
			if (isParentChild) {
				return false;
			}
			return true;
		},
		findLinkDirectional = function (ideaIdFrom, ideaIdTo) {
			return _.find(
				contentAggregate.links,
				function (link) {
					return link.ideaIdFrom == ideaIdFrom && link.ideaIdTo == ideaIdTo; //eslint-disable-line eqeqeq
				}
			);
		};


	contentAggregate.setConfiguration = function (config) {
		configuration = config || {};
	};
	contentAggregate.getSessionKey = function () {
		return sessionKey;
	};
	contentAggregate.setSessionKey = function (newSessionKey) {
		if (contentAggregate.isBatchActive()) {
			throw 'batch-is-active';
		}
		sessionKey = newSessionKey;
	};
	contentAggregate.nextSiblingId = function (subIdeaId) {
		const parentIdea = contentAggregate.findParent(subIdeaId),
			currentRank = parentIdea && parentIdea.findChildRankById(subIdeaId),
			candidateSiblingRanks = currentRank && sameSideSiblingRanks(parentIdea, currentRank),
			siblingsAfter = candidateSiblingRanks && _.reject(candidateSiblingRanks, function (k) {
				return Math.abs(k) <= Math.abs(currentRank);
			});

		if (!parentIdea) {
			return false;
		}

		if (siblingsAfter.length === 0) {
			return false;
		}
		return parentIdea.ideas[_.min(siblingsAfter, Math.abs)].id;
	};
	contentAggregate.sameSideSiblingIds = function (subIdeaId) {
		const parentIdea = contentAggregate.findParent(subIdeaId),
			currentRank = parentIdea.findChildRankById(subIdeaId);
		return _.without(_.map(_.pick(parentIdea.ideas, sameSideSiblingRanks(parentIdea, currentRank)), function (i) {
			return i.id;
		}), subIdeaId);
	};
	contentAggregate.getAttrById = function (ideaId, attrName) {
		const idea = findIdeaById(ideaId);
		return idea && idea.getAttr(attrName);
	};
	contentAggregate.previousSiblingId = function (subIdeaId) {
		const parentIdea = contentAggregate.findParent(subIdeaId),
			currentRank = parentIdea && parentIdea.findChildRankById(subIdeaId),
			candidateSiblingRanks = currentRank && sameSideSiblingRanks(parentIdea, currentRank),
			siblingsBefore = candidateSiblingRanks && _.reject(candidateSiblingRanks, function (k) {
				return Math.abs(k) >= Math.abs(currentRank);
			});

		if (!parentIdea) {
			return false;
		}

		if (siblingsBefore.length === 0) {
			return false;
		}
		return parentIdea.ideas[_.max(siblingsBefore, Math.abs)].id;
	};
	contentAggregate.clone = function (subIdeaId) {
		const toClone = (subIdeaId && subIdeaId != contentAggregate.id && contentAggregate.findSubIdeaById(subIdeaId)) || contentAggregate; //eslint-disable-line eqeqeq
		return JSON.parse(JSON.stringify(toClone));
	};
	contentAggregate.cloneMultiple = function (subIdeaIdArray) {
		return _.map(subIdeaIdArray, contentAggregate.clone);
	};
	contentAggregate.calculatePath = function (ideaId, currentPath, potentialParent) {
		if (contentAggregate.isRootNode(ideaId)) {
			return [];
		}
		currentPath = currentPath || [contentAggregate];
		potentialParent = potentialParent || contentAggregate;
		if (potentialParent.containsDirectChild(ideaId)) {
			return currentPath;
		}
		return _.reduce(
			potentialParent.ideas,
			function (result, child) {
				return result || contentAggregate.calculatePath(ideaId, [child].concat(currentPath), child);
			},
			false
		);
	};
	contentAggregate.getSubTreeIds = function (rootIdeaId) {
		const result = [],
			collectIds = function (idea) {
				if (_.isEmpty(idea.ideas)) {
					return [];
				}
				_.each(idea.sortedSubIdeas(), function (child) {
					collectIds(child);
					result.push(child.id);
				});
			};
		collectIds(contentAggregate.findSubIdeaById(rootIdeaId) || contentAggregate);
		return result;
	};
	contentAggregate.findParent = function (subIdeaId, parentIdea) {
		parentIdea = parentIdea || contentAggregate;
		if (contentAggregate.isRootNode(subIdeaId)) {
			return false;
		}
		if (parentIdea.containsDirectChild(subIdeaId)) {
			return parentIdea;
		}
		return _.reduce(
			parentIdea.ideas,
			function (result, child) {
				return result || contentAggregate.findParent(subIdeaId, child);
			},
			false
		);
	};

	/**** aggregate command processing methods ****/
	contentAggregate.isBatchActive = function (originSession) {
		const activeSession = originSession || sessionKey;
		return !!batches[activeSession];
	};
	contentAggregate.startBatch = function (originSession) {
		const activeSession = originSession || sessionKey;
		contentAggregate.endBatch(originSession);
		batches[activeSession] = [];
	};
	contentAggregate.discardBatch = function (originSession) {
		const activeSession = originSession || sessionKey;
		batches[activeSession] = undefined;
	};
	contentAggregate.endBatch = function (originSession) {
		const activeSession = originSession || sessionKey,
			inBatch = batches[activeSession],
			performBatchOperations = function () {
				const batchArgs = _.map(inBatch, function (event) {
					return [event.eventMethod].concat(event.eventArgs);
				}),
					batchUndoFunctions = _.sortBy(
						_.map(inBatch, function (event) {
							return event.undoFunction;
						}),
						function (f, idx) {
							return -1 * idx;
						}
					),
					undo = function () {
						_.each(batchUndoFunctions, function (eventUndo) {
							eventUndo();
						});
					};
				logChange('batch', batchArgs, undo, activeSession);
			};

		batches[activeSession] = undefined;
		if (_.isEmpty(inBatch)) {
			return;
		}
		if (_.size(inBatch) === 1) {
			logChange(inBatch[0].eventMethod, inBatch[0].eventArgs, inBatch[0].undoFunction, activeSession);
		} else {
			performBatchOperations();
		}
	};
	contentAggregate.execCommand = function (cmd, args, originSession) {
		if (!commandProcessors[cmd]) {
			return false;
		}
		return commandProcessors[cmd].apply(contentAggregate, [originSession || sessionKey].concat(_.toArray(args)));
	};

	contentAggregate.batch = function (batchOp) {
		const hasActiveBatch = contentAggregate.isBatchActive();
		let results;
		if (!hasActiveBatch) {
			contentAggregate.startBatch();
		}
		try {
			results = batchOp();
		} catch (e) {
			if (!hasActiveBatch) {
				contentAggregate.discardBatch();
			}
			throw e;
		}
		if (!hasActiveBatch) {
			contentAggregate.endBatch();
		}
		return results;
	};

	commandProcessors.batch = function (originSession) {
		contentAggregate.startBatch(originSession);
		try {
			_.each(_.toArray(arguments).slice(1), function (event) {
				contentAggregate.execCommand(event[0], event.slice(1), originSession);
			});
		} finally {
			contentAggregate.endBatch(originSession);
		}
	};
	contentAggregate.pasteMultiple = function (parentIdeaId, jsonArrayToPaste) {
		return contentAggregate.batch(function () {
			return _.map(jsonArrayToPaste, function (json) {
				return contentAggregate.paste(parentIdeaId, json);
			});
		});
	};

	contentAggregate.paste = function (/*parentIdeaId, jsonToPaste, initialId*/) {
		return contentAggregate.execCommand('paste', arguments);
	};
	commandProcessors.paste = function (originSession, parentIdeaId, jsonToPaste, initialId) {
		const pasteParent = (parentIdeaId == contentAggregate.id) ? contentAggregate : contentAggregate.findSubIdeaById(parentIdeaId), //eslint-disable-line eqeqeq
			cleanUp = function (json) {
				const result = _.omit(json, 'ideas', 'id', 'attr');
				let index = 1, childKeys, sortedChildKeys;
				result.attr = _.omit(json.attr, configuration.nonClonedAttributes);
				if (_.isEmpty(result.attr)) {
					delete result.attr;
				}
				if (json.ideas) {
					childKeys = _.groupBy(_.map(_.keys(json.ideas), parseFloat), function (key) {
						return key > 0;
					});
					sortedChildKeys = _.sortBy(childKeys[true], Math.abs).concat(_.sortBy(childKeys[false], Math.abs)); //eslint-disable-line dot-notation
					result.ideas = {};
					_.each(sortedChildKeys, function (key) {
						result.ideas[index++] = cleanUp(json.ideas[key]); // eslint-disable-line no-plusplus
					});
				}
				return result;
			};

		let newIdea = undefined, newRank = 0;

		if (initialId) {
			cachedId = parseInt(initialId, 10) - 1;
		}
		newIdea = jsonToPaste && (jsonToPaste.title || jsonToPaste.attr) && init(cleanUp(jsonToPaste), sessionFromId(initialId));
		if (!pasteParent || !newIdea) {
			return false;
		}
		newRank = appendSubIdea(pasteParent, newIdea);
		if (initialId) {
			invalidateIdCache();
		}
		updateAttr(newIdea, 'position');
		logChange('paste', [parentIdeaId, jsonToPaste, newIdea.id], function () {
			delete pasteParent.ideas[newRank];
		}, originSession);
		return newIdea.id;
	};
	contentAggregate.flip = function (/*ideaId*/) {
		return contentAggregate.execCommand('flip', arguments);
	};
	commandProcessors.flip = function (originSession, ideaId) {
		const parentIdea = contentAggregate.findParent(ideaId),
			currentRank = parentIdea && contentAggregate.isRootNode(parentIdea.id) && parentIdea.findChildRankById(ideaId),
			performFlip = function () {
				const maxRank = maxKey(parentIdea.ideas, -1 * sign(currentRank)),
					newRank = maxRank - 10 * sign(currentRank),
					undoFunction = reorderChild(parentIdea, newRank, currentRank);
				logChange('flip', [ideaId], undoFunction, originSession);
			};
		if (!currentRank) {
			return false;
		}
		performFlip();
		return true;
	};
	contentAggregate.initialiseTitle = function (/*ideaId, title*/) {
		return contentAggregate.execCommand('initialiseTitle', arguments);
	};
	commandProcessors.initialiseTitle = function (originSession, ideaId, title) {
		const idea = findIdeaById(ideaId),
			originalTitle = idea && idea.title;

		if (!idea) {
			return false;
		}

		if (originalTitle === title) {
			return false;
		}
		idea.title = title;
		appendChange('initialiseTitle', [ideaId, title], function () {
			idea.title = originalTitle;
		}, originSession);
		return true;
	};
	contentAggregate.updateTitle = function (/*ideaId, title*/) {
		return contentAggregate.execCommand('updateTitle', arguments);
	};
	commandProcessors.updateTitle = function (originSession, ideaId, title) {
		const idea = findIdeaById(ideaId),
			originalTitle = idea && idea.title;
		if (!idea) {
			return false;
		}
		if (originalTitle === title) {
			return false;
		}
		idea.title = title;
		logChange('updateTitle', [ideaId, title], function () {
			idea.title = originalTitle;
		}, originSession);
		return true;
	};
	contentAggregate.addSubIdea = function (/*parentId, ideaTitle, optionalNewId, optionalAttr*/) {
		return contentAggregate.execCommand('addSubIdea', arguments);
	};
	commandProcessors.addSubIdea = function (originSession, parentId, ideaTitle, optionalNewId, optionalAttr) {
		const parent = findIdeaById(parentId),
			createIdeaParams = () => {
				const params = {
					title: ideaTitle,
					id: optionalNewId
				};
				if (optionalAttr) {
					params.attr = optionalAttr;
				}
				return params;
			},
			performAdd = function () {
				const idea = init(createIdeaParams()),
					newRank = appendSubIdea(parent, idea);
				logChange('addSubIdea', [parentId, ideaTitle, idea.id, optionalAttr], function () {
					delete parent.ideas[newRank];
				}, originSession);
				return idea.id;
			};
		if (!parent) {
			return false;
		}
		if (optionalNewId && findIdeaById(optionalNewId)) {
			return false;
		}
		return performAdd();
	};
	contentAggregate.removeMultiple = function (subIdeaIdArray) {
		let results = false;
		contentAggregate.startBatch();
		results = _.map(subIdeaIdArray, contentAggregate.removeSubIdea);
		contentAggregate.endBatch();
		return results;
	};
	contentAggregate.removeSubIdea = function (/*subIdeaId*/) {
		return contentAggregate.execCommand('removeSubIdea', arguments);
	};
	commandProcessors.removeSubIdea = function (originSession, subIdeaId) {
		const canRemove = function () {
			return !contentAggregate.isRootNode(subIdeaId) || _.size(contentAggregate.ideas) > 1;
		},
			performRemove = function () {
				const parent = contentAggregate.findParent(subIdeaId) || contentAggregate,
					oldRank = parent && parent.findChildRankById(subIdeaId),
					oldIdea = parent && parent.ideas[oldRank],
					oldLinks = contentAggregate.links,
					removedNodeIds = {};


				if (!oldRank) {
					return false;
				}
				oldIdea.traverse((traversed) => removedNodeIds[traversed.id] = true);
				delete parent.ideas[oldRank];

				contentAggregate.links = _.reject(contentAggregate.links, function (link) {
					return removedNodeIds[link.ideaIdFrom] || removedNodeIds[link.ideaIdTo];
				});
				logChange('removeSubIdea', [subIdeaId], function () {
					parent.ideas[oldRank] = oldIdea;
					contentAggregate.links = oldLinks;
				}, originSession);
				return true;
			};

		if (!canRemove()) {
			return false;
		}
		return performRemove();
	};
	contentAggregate.insertIntermediateMultiple = function (idArray, ideaOptions) {
		return contentAggregate.batch(function () {
			const newId = contentAggregate.insertIntermediate(idArray[0], ideaOptions && ideaOptions.title);
			if (ideaOptions && ideaOptions.attr) {
				Object.keys(ideaOptions.attr).forEach(function (key) {
					contentAggregate.updateAttr(newId, key, ideaOptions.attr[key]);
				});
			}
			_.each(idArray.slice(1), function (id) {
				contentAggregate.changeParent(id, newId);
			});
			return newId;
		});
	};
	contentAggregate.insertIntermediate = function (/*inFrontOfIdeaId, title, optionalNewId, optionalAttr*/) {
		return contentAggregate.execCommand('insertIntermediate', arguments);
	};
	commandProcessors.insertIntermediate = function (originSession, inFrontOfIdeaId, title, optionalNewId, optionalAttr) {
		const parentIdea = contentAggregate.isRootNode(inFrontOfIdeaId) ? contentAggregate : contentAggregate.findParent(inFrontOfIdeaId),
			childRank = parentIdea && parentIdea.findChildRankById(inFrontOfIdeaId),
			canInsert = function () {
				if (contentAggregate.id == inFrontOfIdeaId) { //eslint-disable-line eqeqeq
					return false;
				}
				if (!parentIdea) {
					return false;
				}
				if (optionalNewId && findIdeaById(optionalNewId)) {
					return false;
				}

				if (!childRank) {
					return false;
				}
				return true;
			},
			performInsert = function () {
				const createIdeaParams = () => {
					const params = {
						title: title,
						id: optionalNewId
					};
					if (optionalAttr) {
						params.attr = optionalAttr;
					}
					return params;
				},
					oldIdea = parentIdea.ideas[childRank],
					newIdea = init(createIdeaParams());

				parentIdea.ideas[childRank] = newIdea;
				newIdea.ideas = {
					1: oldIdea
				};
				logChange('insertIntermediate', [inFrontOfIdeaId, title, newIdea.id, optionalAttr], function () {
					parentIdea.ideas[childRank] = oldIdea;
				}, originSession);
				return newIdea.id;
			};

		if (!canInsert()) {
			return false;
		}
		return performInsert();

	};
	contentAggregate.changeParent = function (/*ideaId, newParentId*/) {
		return contentAggregate.execCommand('changeParent', arguments);
	};
	commandProcessors.changeParent = function (originSession, ideaId, newParentId) {
		const parent = findIdeaById(newParentId),
			idea = contentAggregate.findSubIdeaById(ideaId),
			oldParent = contentAggregate.isRootNode(ideaId) ? contentAggregate : contentAggregate.findParent(ideaId),
			canChangeParent = function () {
				if (ideaId == newParentId) { // eslint-disable-line eqeqeq
					return false;
				}
				if (!parent) {
					return false;
				}

				if (!idea) {
					return false;
				}
				if (idea.findSubIdeaById(newParentId)) {
					return false;
				}
				if (parent.containsDirectChild(ideaId)) {
					return false;
				}
				if (!oldParent) {
					return false;
				}
				return true;
			},
			performChangeParent = function () {
				const oldRank = oldParent.findChildRankById(ideaId),
					newRank = appendSubIdea(parent, idea),
					oldPosition = idea.getAttr('position');

				updateAttr(idea, 'position');
				delete oldParent.ideas[oldRank];
				logChange('changeParent', [ideaId, newParentId], function () {
					updateAttr(idea, 'position', oldPosition);
					oldParent.ideas[oldRank] = idea;
					delete parent.ideas[newRank];
				}, originSession);
			};
		if (!canChangeParent()) {
			return false;
		}
		performChangeParent();
		return true;
	};
	contentAggregate.mergeAttrProperty = function (ideaId, attrName, attrPropertyName, attrPropertyValue) {
		let val = contentAggregate.getAttrById(ideaId, attrName) || {};
		if (attrPropertyValue) {
			val[attrPropertyName] = attrPropertyValue;
		} else {
			delete val[attrPropertyName];
		}
		if (_.isEmpty(val)) {
			val = false;
		}
		return contentAggregate.updateAttr(ideaId, attrName, val);
	};
	contentAggregate.updateAttr = function (/*ideaId, attrName, attrValue*/) {
		return contentAggregate.execCommand('updateAttr', arguments);
	};
	commandProcessors.updateAttr = function (originSession, ideaId, attrName, attrValue) {
		const idea = findIdeaById(ideaId),
			undoAction = updateAttr(idea, attrName, attrValue);
		if (undoAction) {
			logChange('updateAttr', [ideaId, attrName, attrValue], undoAction, originSession);
		}
		return !!undoAction;
	};
	contentAggregate.getOrderedSiblingRanks = function (ideaId, options) {
		const parentIdea = contentAggregate.findParent(ideaId),
			currentRank = parentIdea && parentIdea.findChildRankById(ideaId);
		if (!currentRank) {
			return false;
		}
		if (options && options.ignoreRankSide) {
			return _.sortBy(_.map(_.keys(parentIdea.ideas), parseFloat));
		} else {
			return _.sortBy(sameSideSiblingRanks(parentIdea, currentRank), Math.abs);
		}
	};
	contentAggregate.moveRelative = function (ideaId, relativeMovement, options) {
		const parentIdea = contentAggregate.findParent(ideaId),
			currentRank = parentIdea && parentIdea.findChildRankById(ideaId),
			siblingRanks = contentAggregate.getOrderedSiblingRanks(ideaId, options),
			currentIndex = siblingRanks && siblingRanks.indexOf(currentRank),
			calcNewIndex = function () {
				let calcIndex = currentIndex + (relativeMovement > 0 ? relativeMovement + 1 : relativeMovement);
				if (options && options.ignoreRankSide) {
					if (currentRank < 0) {
						calcIndex = currentIndex + (relativeMovement < 0 ? relativeMovement - 1 : relativeMovement);
						if (siblingRanks[calcIndex] > 0) {
							calcIndex = calcIndex + 1;
						}
					} else if (siblingRanks[calcIndex] < 0) {
						calcIndex = calcIndex - 1;
					}
				}
				return calcIndex;

			},
			/* we call positionBefore, so movement down is actually 2 spaces, not 1 */
			newIndex = calcNewIndex(),
			beforeRank = newIndex >= 0 && siblingRanks && siblingRanks.length && siblingRanks[newIndex],
			beforeSibling = beforeRank && parentIdea && parentIdea.ideas[beforeRank],
			shouldNotPosition = function () {
				if (!parentIdea) {
					return false;
				}
				if (options && options.ignoreRankSide && currentRank < 0) {
					return newIndex > (siblingRanks.length - 1);
				}
				return (newIndex < 0);
			};
		let result = false;
		if (shouldNotPosition()) {
			return false;
		}
		contentAggregate.startBatch();
		//handle reordering on top down maps where moving from positive to negative or vice versa
		if (options && options.ignoreRankSide && beforeRank && beforeSibling && ((beforeRank * currentRank) < 0)) {
			contentAggregate.flip(ideaId);
		}
		result = contentAggregate.positionBefore(ideaId, beforeSibling && beforeSibling.id, parentIdea);
		contentAggregate.endBatch();
		return result;
	};
	contentAggregate.positionBefore = function (/*ideaId, positionBeforeIdeaId, parentIdea*/) {
		return contentAggregate.execCommand('positionBefore', arguments);
	};
	commandProcessors.positionBefore = function (originSession, ideaId, positionBeforeIdeaId, parentIdeaArg) {
		let newRank, afterRank, siblingRanks, candidateSiblings, beforeRank, maxRank, undoFunction = undefined;
		const parentIdea = parentIdeaArg || contentAggregate.findParent(ideaId),
			currentRank = parentIdea && parentIdea.findChildRankById(ideaId);

		if (!parentIdea) {
			return false;
		}

		if (ideaId == positionBeforeIdeaId) { //eslint-disable-line eqeqeq
			return false;
		}
		newRank = 0;
		if (positionBeforeIdeaId) {
			afterRank = parentIdea.findChildRankById(positionBeforeIdeaId);
			if (!afterRank) {
				return false;
			}
			siblingRanks = sameSideSiblingRanks(parentIdea, afterRank);
			candidateSiblings = _.reject(_.sortBy(siblingRanks, Math.abs), function (k) {
				return Math.abs(k) >= Math.abs(afterRank);
			});
			beforeRank = candidateSiblings.length > 0 ? _.max(candidateSiblings, Math.abs) : 0;
			if (beforeRank == currentRank) { //eslint-disable-line eqeqeq
				return false;
			}
			newRank = beforeRank + (afterRank - beforeRank) / 2;
		} else {
			maxRank = maxKey(parentIdea.ideas, currentRank < 0 ? -1 : 1);
			if (maxRank == currentRank) { //eslint-disable-line eqeqeq
				return false;
			}
			newRank = maxRank + 10 * (currentRank < 0 ? -1 : 1);
		}
		if (newRank == currentRank) { //eslint-disable-line eqeqeq
			return false;
		}
		undoFunction = reorderChild(parentIdea, newRank, currentRank);
		logChange('positionBefore', [ideaId, positionBeforeIdeaId], undoFunction, originSession);
		return true;
	};

	contentAggregate.addLink = function (/*ideaIdFrom, ideaIdTo*/) {
		return contentAggregate.execCommand('addLink', arguments);
	};
	commandProcessors.addLink = function (originSession, ideaIdFrom, ideaIdTo) {
		const link = {
			ideaIdFrom: ideaIdFrom,
			ideaIdTo: ideaIdTo,
			attr: {
				style: {
					color: 'red', // changed from #707070 grey
					lineStyle: 'solid',
					arrow: 'to'
				}
			}
		};

		if (!isLinkValid(ideaIdFrom, ideaIdTo)) {
			return false;
		}
		if (findLinkBetween(ideaIdFrom, ideaIdTo)) {
			return false;
		}
		contentAggregate.links = contentAggregate.links || [];
		contentAggregate.links.push(link);
		logChange('addLink', [ideaIdFrom, ideaIdTo], function () {
			contentAggregate.links.pop();
		}, originSession);
		return true;
	};
	contentAggregate.removeLink = function (/*ideaIdOne, ideaIdTwo*/) {
		return contentAggregate.execCommand('removeLink', arguments);
	};
	commandProcessors.removeLink = function (originSession, ideaIdOne, ideaIdTwo) {
		let i = 0, link;

		while (contentAggregate.links && i < contentAggregate.links.length) {
			link = contentAggregate.links[i];
			if (link.ideaIdFrom === ideaIdOne && link.ideaIdTo === ideaIdTwo) { //eslint-disable-line eqeqeq
				contentAggregate.links.splice(i, 1);
				logChange('removeLink', [ideaIdOne, ideaIdTwo], function () {
					contentAggregate.links.push(_.clone(link));
				}, originSession);
				return true;
			}
			i += 1;
		}
		return false;
	};
	contentAggregate.getLinkAttr = function (ideaIdFrom, ideaIdTo, name) {
		const link = findLinkDirectional(ideaIdFrom, ideaIdTo);
		if (link && link.attr && link.attr[name]) {
			return link.attr[name];
		}
		return false;
	};
	contentAggregate.updateLinkAttr = function (/*ideaIdFrom, ideaIdTo, attrName, attrValue*/) {
		return contentAggregate.execCommand('updateLinkAttr', arguments);
	};
	commandProcessors.updateLinkAttr = function (originSession, ideaIdFrom, ideaIdTo, attrName, attrValue) {
		const link = findLinkDirectional(ideaIdFrom, ideaIdTo),
			undoAction = updateAttr(link, attrName, attrValue);
		if (undoAction) {
			logChange('updateLinkAttr', [ideaIdFrom, ideaIdTo, attrName, attrValue], undoAction, originSession);
		}
		return !!undoAction;
	};

	/* undo/redo */
	contentAggregate.canUndo = function () {
		return !!(eventStacks[sessionKey] && eventStacks[sessionKey].length > 0);
	};
	contentAggregate.canRedo = function () {
		return !!(redoStacks[sessionKey] && redoStacks[sessionKey].length > 0);
	};
	contentAggregate.undo = function () {
		return contentAggregate.execCommand('undo', arguments);
	};
	commandProcessors.undo = function (originSession) {
		let topEvent = false;
		contentAggregate.endBatch();
		topEvent = eventStacks[originSession] && eventStacks[originSession].pop();
		if (topEvent && topEvent.undoFunction) {
			topEvent.undoFunction();
			if (!redoStacks[originSession]) {
				redoStacks[originSession] = [];
			}
			redoStacks[originSession].push(topEvent);
			contentAggregate.dispatchEvent('changed', 'undo', [], originSession);
			return true;
		}
		return false;
	};
	contentAggregate.redo = function () {
		return contentAggregate.execCommand('redo', arguments);
	};
	commandProcessors.redo = function (originSession) {
		let topEvent = false;
		contentAggregate.endBatch();
		topEvent = redoStacks[originSession] && redoStacks[originSession].pop();
		if (topEvent) {
			isRedoInProgress = true;
			contentAggregate.execCommand(topEvent.eventMethod, topEvent.eventArgs, originSession);
			isRedoInProgress = false;
			return true;
		}
		return false;
	};
	contentAggregate.storeResource = function (/*resourceBody, optionalKey*/) {
		return contentAggregate.execCommand('storeResource', arguments);
	};
	commandProcessors.storeResource = function (originSession, resourceBody, optionalKey) {
		const maxIdForSession = function () {
			const keys = _.keys(contentAggregate.resources),
				filteredKeys = sessionKey ? _.filter(keys, RegExp.prototype.test.bind(new RegExp('\\/' + sessionKey + '$'))) : keys,
				intKeys = _.map(filteredKeys, function (string) {
					return parseInt(string, 10);
				});
			return _.isEmpty(intKeys) ? 0 : _.max(intKeys);
		},
			nextResourceId = function () {
				const intId = maxIdForSession() + 1;
				return intId + uniqueResourcePostfix;
			},
			getExistingResourceId = function () {
				if (!optionalKey && contentAggregate.resources) {
					return _.find(_.keys(contentAggregate.resources), function (key) {
						return contentAggregate.resources[key] === resourceBody;
					});
				}
			},
			storeNewResource = function () {
				const id = optionalKey || nextResourceId();
				contentAggregate.resources = contentAggregate.resources || {};
				contentAggregate.resources[id] = resourceBody;
				contentAggregate.dispatchEvent('resourceStored', resourceBody, id, originSession);
				return id;
			};

		return getExistingResourceId() || storeNewResource();
	};
	contentAggregate.getResource = function (id) {
		return contentAggregate.resources && contentAggregate.resources[id];
	};
	contentAggregate.hasSiblings = function (id) {
		const parent = contentAggregate.findParent(id);

		if (contentAggregate.isRootNode(id)) {
			return false;
		}

		return parent && _.size(parent.ideas) > 1;
	};
	contentAggregate.isRootNode = function (id) {
		return isRootNode(id);
	};
	contentAggregate.getDefaultRootId = function () {
		const rootNodes = contentAggregate && _.values(contentAggregate.ideas);
		return rootNodes && rootNodes.length && rootNodes[0].id;
	};

	contentUpgrade(contentAggregate);
	observable(contentAggregate);
	init(contentAggregate);
	return contentAggregate;
};
