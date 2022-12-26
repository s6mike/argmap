/*global require, mapInstance, getContainerID*/
const $ = require('jquery'),
	// Moved exports-loader call to webpack.config.js
	// Hammer = require('jquery-hammerjs/jquery.hammer-full.js'),
	Hammer = require('hammerjs'),
	// mapModel = mapInstance[getContainerID(this)].mapModel,

	onDrag = function (e) {
		'use strict';
		this.dispatchEvent(
			// $(this).trigger(
			new Event('mm:start-dragging', {
				relatedTarget: this,
				gesture: e.gesture
			})
		);
		e.stopPropagation();
		e.preventDefault();
		if (e.gesture) {
			e.gesture.stopPropagation();
			e.gesture.preventDefault();
		}
	},
	onShadowDrag = function (e) {
		'use strict';
		// TODO: Move mapModel definition to outer scope if possible:
		const mapModel = mapInstance[getContainerID(this)].mapModel;
		if (mapModel.getInputEnabled()) {
			this.dispatchEvent(
				new Event('mm:start-dragging-shadow', {
				// $(this).trigger(
				// $.Event('mm:start-dragging-shadow', {
					relatedTarget: this,
					gesture: e.gesture
				})
			);
			e.stopPropagation();
			e.preventDefault();
			if (e.gesture) {
				e.gesture.stopPropagation();
				e.gesture.preventDefault();
			}
		}
	};


$.fn.simpleDraggableContainer = function () {
	'use strict';
	let currentDragObject,
		originalDragObjectPosition;
	const container = this[0],
		drag = function (event) {

			if (currentDragObject && event.gesture) {
				const newpos = {
					top: Math.round(parseInt(originalDragObjectPosition.top, 10) + event.gesture.deltaY),
					left: Math.round(parseInt(originalDragObjectPosition.left, 10) + event.gesture.deltaX)
				};
				// currentDragObject.css(newpos).trigger($.Event('mm:drag', {currentPosition: newpos, gesture: event.gesture}));
				currentDragObject.css(newpos).dispatchEvent(new Event('mm:drag', { currentPosition: newpos, gesture: event.gesture }));
				if (event.gesture) {
					event.gesture.preventDefault();
				}
				return false;
			}
		},
		rollback = function (e) {
			const target = currentDragObject; // allow it to be cleared while animating
			if (target.attr('mapjs-drag-role') !== 'shadow') {
				target.animate(originalDragObjectPosition, {
					complete: function () {
						// target.trigger($.Event('mm:cancel-dragging', {gesture: e.gesture}));
						target.dispatchEvent(new Event('mm:cancel-dragging', { gesture: e.gesture }));
					},
					progress: function () {
						// target.trigger('mm:drag');
						target.dispatchEvent(new Event('mm:drag'));
					}
				});
			} else {
				// target.trigger($.Event('mm:cancel-dragging', {gesture: e.gesture}));
				target.dispatchEvent(new Event('mm:cancel-dragging', { gesture: e.gesture }));
			}
		},
		hammer_container = Hammer(container, { 'drag_min_distance': 2 }); //eslint-disable-line new-cap
	hammer_container.on('mm:start-dragging', function (event) {
		if (!currentDragObject) {
			currentDragObject = $(event.relatedTarget);
			originalDragObjectPosition = {
				top: currentDragObject.css('top'),
				left: currentDragObject.css('left')
			};
			hammer_container.on('drag', drag);
		}
	}).on('mm:start-dragging-shadow', function (event) {
		const target = $(event.relatedTarget),
			clone = function () {
				const result = target.clone().addClass('drag-shadow').appendTo(container).offset(target.offset()).data(target.data()).attr('mapjs-drag-role', 'shadow'),
					scale = target.parent().data('scale') || 1;
				if (scale !== 0) {
					result.css({
						'transform': 'scale(' + scale + ')',
						'transform-origin': 'top left'
					});
				}
				return result;
			};
		if (!currentDragObject) {
			currentDragObject = clone();
			originalDragObjectPosition = {
				top: currentDragObject.css('top'),
				left: currentDragObject.css('left')
			};
			currentDragObject.on('mm:stop-dragging mm:cancel-dragging', function (e) {
				this.remove();
				e.stopPropagation();
				e.stopImmediatePropagation();
				const evt = new Event(e.type, {
					gesture: e.gesture,
					finalPosition: e.finalPosition
				});
				// target.trigger(evt);
				target.dispatchEvent(evt);
			}).on('mm:drag', function (e) {
				// target.trigger(e);
				target.dispatchEvent(e);
			});
			$(this).on('drag', drag);
		}
	}).on('dragend', function (e) {
		$(this).off('drag', drag);
		if (currentDragObject) {
			// const evt = $.Event('mm:stop-dragging', {
			const evt = new Event('mm:stop-dragging', {
				gesture: e.gesture,
				finalPosition: currentDragObject.offset()
			});
			// currentDragObject.trigger(evt);
			currentDragObject.dispatchEvent(evt);
			if (evt.result === false) {
				rollback(e);
			}
			currentDragObject = undefined;
		}
	}).on('mouseleave', function (e) {
		if (currentDragObject) {
			$(this).off('drag', drag);
			rollback(e);
			currentDragObject = undefined;
		}
	});
	return container.setAttribute('data-drag-role', 'container');
};

$.fn.simpleDraggable = function (options) {
	'use strict';
	if (!options || !options.disable) {
		return $(this).on('dragstart', onDrag);
	} else {
		return $(this).off('dragstart', onDrag);
	}
};
$.fn.shadowDraggable = function (options) {
	'use strict';
	if (!options || !options.disable) {
		return $(this).on('dragstart', onShadowDrag);
	} else {
		return $(this).off('dragstart', onShadowDrag);
	}
};
