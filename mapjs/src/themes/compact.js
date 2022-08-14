var MAPJS = MAPJS || {};
MAPJS.Themes = MAPJS.Themes || {};
MAPJS.Themes.compact = {
				'name': 'MindMup Compact',
				'node': [
					{
						'name': 'default',
						'cornerRadius': 3.0,
						'background': {
							'color': 'transparent',
							'opacity': 0.0
						},
						'border': {
							'type': 'underline'
						},
						'shadow': [
						{
							'color': 'transparent'
						}
						],
						'text': {
							'margin': 5.0,
							'alignment': 'left',
							'color': '#4F4F4F',
							'lightColor': '#EEEEEE',
							'darkColor': '#000000',
							'font': {
								'lineSpacing': 8,
								'size': 12,
								'weight': 'light'
							}
						},
						'connections': {
							'default': {
								'h': 'nearest',
								'v': 'base'
							}
						},
						'decorations': {
							'height': 32,
							'edge': 'top',
							'overlap': false,
							'position': 'center'
						}
					},
					{
						'name': 'level_1',
						'connections': {
							'default': {
								'h': 'nearest',
								'v': 'center'
							}
						}
					},
					{
						'name': 'activated',
						'border': {
							'type': 'surround',
							'line': {
								'color': '#22AAE0',
								'width': 2.0,
								'style': 'dashed'
							}
						}
					},
					{
						'name': 'selected',
						'shadow': [
						{
							'color': '#FFFFFF',
							'offset': {
								'width': 1,
								'height': 0
							},
							'radius': 0
						},
						{
							'color': '#FFFFFF',
							'offset': {
								'width': -1,
								'height': 0
							},
							'radius': 0
						},
						{
							'color': '#22AAE0',
							'offset': {
								'width': 4,
								'height': 0
							},
							'radius': 0
						},
						{
							'color': '#22AAE0',
							'offset': {
								'width': -4,
								'height': 0
							},
							'radius': 0
						}

						]
					},
					{
						'name': 'collapsed',
						'shadow': [
						{
							'color': '#888888',
							'offset': {
								'width': 0,
								'height': 1
							},
							'radius': 0
						},
						{
							'color': '#FFFFFF',
							'offset': {
								'width': 0,
								'height': 3
							},
							'radius': 0
						},
						{
							'color': '#888888',
							'offset': {
								'width': 0,
								'height': 4
							},
							'radius': 0
						},
						{
							'color': '#FFFFFF',
							'offset': {
								'width': 0,
								'height': 6
							},
							'radius': 0
						},
						{
							'color': '#888888',
							'offset': {
								'width': 0,
								'height': 7
							},
							'radius': 0
						}
						]
					},
					{
						'name': 'collapsed.selected',
						'shadow': [
						{
							'color': '#FFFFFF',
							'offset': {
								'width': 1,
								'height': 0
							},
							'radius': 0
						},
						{
							'color': '#FFFFFF',
							'offset': {
								'width': -1,
								'height': 0
							},
							'radius': 0
						},
						{
							'color': '#22AAE0',
							'offset': {
								'width': 4,
								'height': 0
							},
							'radius': 0
						},
						{
							'color': '#22AAE0',
							'offset': {
								'width': -4,
								'height': 0
							},
							'radius': 0
						},
						{
							'color': '#888888',
							'offset': {
								'width': 0,
								'height': 1
							},
							'radius': 0
						},
						{
							'color': '#FFFFFF',
							'offset': {
								'width': 0,
								'height': 3
							},
							'radius': 0
						},
						{
							'color': '#888888',
							'offset': {
								'width': 0,
								'height': 4
							},
							'radius': 0
						},
						{
							'color': '#FFFFFF',
							'offset': {
								'width': 0,
								'height': 6
							},
							'radius': 0
						},
						{
							'color': '#888888',
							'offset': {
								'width': 0,
								'height': 7
							},
							'radius': 0
						}
						]
					}

				],
				'connector': {
					'default': {
						'type': 'compact-s-curve',
						'line': {
							'color': '#707070',
							'width': 1.0
						}
					}
				}
			};
