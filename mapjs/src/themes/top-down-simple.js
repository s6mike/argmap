var MAPJS = MAPJS || {};
MAPJS.Themes = MAPJS.Themes || {};
MAPJS.Themes.topdown = {
	'name': 'MindMup Top Down Straight Lines',
	'layout': {
		'orientation': 'top-down',
		'spacing': {
			'h': 20,
			'v': 100
		}
	},
	'node': [
		{
			'name': 'default',
			'cornerRadius': 5.0,
			'background': {
				'color': 'transparent',
				'opacity': 0.0
			},
			'border': {
				'type': 'overline'
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
					'lineSpacing': 2,
					'size': 10,
					'weight': 'light'
				}
			},
			'connections': {
				'default': {
					'h': 'center',
					'v': 'base'
				},
				'from': {
					'horizontal': {
						'h': 'center',
						'v': 'base'
					}
				},
				'to': {
					'h': 'center',
					'v': 'top'
				}
			},
			'decorations': {
				'height': 32,
				'edge': 'right',
				'overlap': true,
				'position': 'center'
			}
		},
		{
			'name': 'activated',
			'border': {
				'type': 'surround',
				'line': {
					'color': '#22AAE0',
					'width': 3.0,
					'style': 'dotted'
				}
			}
		},
		{
			'name': 'selected',
			'shadow': [
			{
				'color': '#000000',
				'opacity': 0.9,
				'offset': {
					'width': 2,
					'height': 2
				},
				'radius': 2
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
					'width': 0,
					'height': 1
				},
				'radius': 0
			},
			{
				'color': '#888888',
				'offset': {
					'width': 0,
					'height': 3
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
				'color': '#555555',
				'offset': {
					'width': 0,
					'height': 7
				},
				'radius': 0
			},
			{
				'color': '#FFFFFF',
				'offset': {
					'width': 0,
					'height': 10
				},
				'radius': 0
			},
			{
				'color': '#333333',
				'offset': {
					'width': 0,
					'height': 11
				},
				'radius': 0
			}
			]
		}
	],
	'connector': {
		'default': {
			'type': 'top-down-s-curve',
			'line': {
				'color': '#707070',
				'width': 2.0
			}
		}
	}
};

