var MAPJS = MAPJS || {};
MAPJS.Themes = MAPJS.Themes || {};
MAPJS.Themes.argumentMapping = {
	'name': 'MindMup Top Down Argument Mapping',
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
					'h': 'center-separated',
					'v': 'base'
				},
				'from': {
					'horizontal': {
						'h': 'center-separated',
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
			'name': 'level_1',
			'cornerRadius': 10.0,
			'text': {
				'margin': 10.0,
				'alignment': 'center',
				'color': '#4F4F4F',
				'lightColor': '#EEEEEE',
				'darkColor': '#000000',
				'font': {
					'lineSpacing': 2,
					'size': 15,
					'weight': 'light'
				}
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
		},
		{
			'name': 'attr_group',
			'cornerRadius': 10.0,
			'text': {
				'margin': 0.0,
				'alignment': 'center',
				'color': '#4F4F4F',
				'lightColor': '#EEEEEE',
				'darkColor': '#000000',
				'font': {
					'lineSpacing': 2.5,
					'size': 9,
					'weight': 'bold'
				}
			},
			'connections': {
				'style': 'supporting-group',
				'childstyle': 'no-connector',
				'default': {
					'h': 'center',
					'v': 'base'
				},
				'from': {
					'below': {
						'h': 'center',
						'v': 'base'
					}
				},
				'to': {
					'h': 'center',
					'v': 'top'
				}
			}
		},
		{
			'name': 'attr_group_supporting',
			'connections': {
				'style': 'supporting-group',
				'childstyle': 'no-connector',
				'default': {
					'h': 'center',
					'v': 'base'
				},
				'from': {
					'below': {
						'h': 'center',
						'v': 'base'
					}
				},
				'to': {
					'h': 'center',
					'v': 'top'
				}
			}
		},
		{
			'name': 'attr_group_supporting.activated',
			'background': {
				'color': '#00FF00',
				'opacity': 0.2
			},
			'border': {
				'type': 'surround',
				'line': {
					'color': '#00FF00',
					'width': 3.0,
					'style': 'dotted'
				}
			}
		},
		{
			'name': 'attr_group_opposing',
			'connections': {
				'style': 'opposing-group',
				'childstyle': 'no-connector',
				'default': {
					'h': 'center',
					'v': 'base'
				},
				'from': {
					'below': {
						'h': 'center',
						'v': 'base'
					}
				},
				'to': {
					'h': 'center',
					'v': 'top'
				}
			}
		},
		{
			'name': 'attr_group_opposing.activated',
			'background': {
				'color': '#FF0000',
				'opacity': 0.2
			},
			'border': {
				'type': 'surround',
				'line': {
					'color': '#FF0000',
					'width': 3.0,
					'style': 'dotted'
				}
			}
		}
	],
	'connector': {
		'default': {
			'type': 'vertical-quadratic-s-curve',
			'line': {
				'color': '#707070',
				'width': 1.0
			}
		},
		'no-connector': {
			'type': 'no-connector',
			'line': {
				'color': '#707070',
				'width': 0.0
			}
		},
		'supporting-group': {
			'type': 'vertical-quadratic-s-curve',
			'line': {
				'color': '#00FF00',
				'width': 3.0
			}
		},
		'opposing-group': {
			'type': 'vertical-quadratic-s-curve',
			'line': {
				'color': '#FF0000',
				'width': 3.0
			}
		},
		'no-connector.supporting-group': {
			'type': 'no-connector',
			'line': {
				'color': '#00FF00',
				'width': 4.0
			}
		},
		'no-connector.opposing-group': {
			'type': 'no-connector',
			'line': {
				'color': '#FF0000',
				'width': 4.0
			}
		}
	}
};

