/**
 * Virtual Assistant (VAT) Chat Room.
 *
 * @package VAT extension for SketchUp
 *
 * @copyright © 2019 Samuel Tallet
 *
 * @licence GNU General Public License 3.0
 */

/**
 * VAT plugin namespace.
 */
VAT = {}

/**
 * User name.
 */
VAT.userName = ''

/**
 * Memory.
 */
VAT.memory = {}


/**
 * Capabilities.
 */	
VAT.capabilities = [

	'Open a file.',
	'Clean model.',
	'Select first object.',
	'Select first group.',
	'Select group with name ...',
	'Select first instance.',
	'Select instance with name ...',
	'Move.',
	'Rotate by 90 degrees.',
	'Increase size 2 times.',
	'Name ...',
	'Duplicate and name ...',
	'Clear selection.',
	'Delete.',
	'Activate Push Pull tool.',
	'Activate Rectangle tool.',
	'Activate ... tool.',
	'Draw a cube.',
	'Draw a cone.',
	'Draw a cylinder.',
	'Draw a prism.',
	'Draw a pyramid.',
	'Draw a sphere.',
	'Write ...',
	'Search an extension about ...'

]

/**
 * Save memory each 5 seconds.
 */
VAT.saveMemoryRegularly = () => {

	window.setInterval(() => {

		sketchup.saveMemory(VAT.memory)

	}, 5000)

}

/**
 * Enables user input auto-completion.
 *
 * @return {void}
 */
VAT.enableAutoComplete = () => {

	new autoComplete({

		selector: '#user-input',

		minChars: 2,

		source: (term, suggest) => {

			term = term.toLowerCase();
			
			var suggestions = [];

			for (i = 0; i < VAT.capabilities.length; i++) {

				if ( ~VAT.capabilities[i].toLowerCase().indexOf(term) ) {

					suggestions.push(VAT.capabilities[i])

				}

			}

			suggest(suggestions)

		}

	})

}

/**
 * Capitalizes first letter of a string.
 *
 * @param {string} string
 *
 * @return {string}
 */
VAT.capitalize = string => {

    return string.charAt(0).toUpperCase() + string.slice(1)

}

/**
 * Converts a string to camel case.
 *
 * @param {string} string
 *
 * @return {string}
 */
VAT.camelize = string => {

  return string.replace(/(?:^\w|[A-Z]|\b\w)/g, (word, index) => {

    return index == 0 ? word.toLowerCase() : word.toUpperCase()

  }).replace(/\s+/g, '')

}

/**
 * Calculates Levenshtein distance between two given strings.
 *
 * @see https://gist.github.com/andrei-m/982927#gistcomment-1931258
 *
 * @return {number}
 */
VAT.levenshtein = (a, b) => {

  if (a.length === 0) return b.length
  if (b.length === 0) return a.length

  let tmp, i, j, prev, val, row

  // swap to save some memory O(min(a,b)) instead of O(a)
  if (a.length > b.length) {

    tmp = a
    a = b
    b = tmp

  }

  row = Array(a.length + 1)

  // init the row
  for (i = 0; i <= a.length; i++) {

    row[i] = i

  }

  // fill in the rest
  for (i = 1; i <= b.length; i++) {

    prev = i

    for (j = 1; j <= a.length; j++) {

      if (b[i-1] === a[j-1]) {

        val = row[j-1] // match

      } else {

        val = Math.min(row[j-1] + 1, // substitution
              Math.min(prev + 1,     // insertion
                       row[j] + 1))  // deletion
      }

      row[j - 1] = prev
      prev = val

    }

    row[a.length] = prev
  }

  return row[a.length]

}

/**
 * "Did you mean" deduces a capability from an input message.
 */
VAT.didYouMean = inputMessage => {

	var inputVerb = inputMessage.replace(/ .*/, '');

	var minDistance = Infinity
	var bestMatch = ''

	VAT.capabilities.forEach(capability => {

		var capabilityVerb = capability.replace(/ .*/, '');

		if ( capabilityVerb != '' ) {

			var distance = VAT.levenshtein(inputVerb, capabilityVerb)

			if ( distance <= minDistance ) {

				minDistance = distance

				bestMatch = capability

			}

		}

	})

	return bestMatch

}

/**
 * Returns a random synonym for an expression.
 *
 * @param {string} expr Expression.
 *
 * @return {string} Synonym.
 */
VAT.synonym = expr => {

	switch (expr) {

		case 'I take note.':

			var array = ['I take note.', 'Noted.', 'It\'s understood.']

			return array[Math.floor(Math.random() * array.length)]

			break

		case 'OK.':

			var array = ['OK.', 'Okay.', 'Good idea.', 'Let\'s go!']

			return array[Math.floor(Math.random() * array.length)]

			break

		case 'It\'s done.':

			var array = ['It\'s done.', 'Mission complete.']

			return array[Math.floor(Math.random() * array.length)]

			break

		case 'You\'re welcome.':

			var array = ['You\'re welcome.', 'No problem.', '😉']

			return array[Math.floor(Math.random() * array.length)]

			break

	}

	return expr

}

/**
 * Interacts with chat bot...
 *
 * @param {string} inputMessage
 *
 * @return {string} Output message.
 */
VAT.chatBot = inputMessage => {

	VAT.userSay(inputMessage)

	var outputMessages = []

	var doc = nlp(inputMessage)

	// Greetings.

	if ( doc.has('(hello|hi|hey)') ) {

		outputMessages.push('Hello ' + VAT.userName + '!')

	}

	// Math.

	if ( /\d+ *\+ *\d+/g.test(inputMessage) ) {

		var integers = inputMessage.match(/(\d+)/g)

		outputMessages.push(parseInt(integers[0]) + parseInt(integers[1]))

	} else if ( /\d+ *- *\d+/g.test(inputMessage) ) {

		var integers = inputMessage.match(/(\d+)/g)

		outputMessages.push(parseInt(integers[0]) - parseInt(integers[1]))

	} else if ( /\d+ *\* *\d+/g.test(inputMessage) ) {

		var integers = inputMessage.match(/(\d+)/g)

		outputMessages.push(parseInt(integers[0]) * parseInt(integers[1]))

	} else if ( /\d+ *\/ *\d+/g.test(inputMessage) ) {

		var integers = inputMessage.match(/(\d+)/g)

		outputMessages.push(parseInt(integers[0]) / parseInt(integers[1]))

	}

	// Subject.

	if ( doc.has('^let\'s talk about .') ) {

		VAT.memory.__subject__ = doc.after('^let\'s talk about').text()

		if ( VAT.memory.__subject__ == 'you' ) {

			VAT.memory.__subject__ = 'me'

		} else if ( VAT.memory.__subject__ == 'me' ) {

			VAT.memory.__subject__ = 'you'

		}

		outputMessages.push(VAT.synonym('OK.'))

	} else if ( doc.has('^what are we talking about') ) {

		outputMessages.push('We\'re talking about ' + VAT.memory.__subject__ + '.')

	}

	// Time.

	if ( doc.has('^what time is it') ) {

		var date = new Date()

		outputMessages.push(date.getHours() + ':' + date.getMinutes() + ':' + date.getSeconds())

	} else

	// Quality.

	if ( doc.has('. is a .') ) {

		var object = doc.match('[.] is a').text('normal')

		var a_class = doc.after('. is a').text('normal')

		if ( !VAT.memory[object] ) {

			VAT.memory[object] = {}

		}

		if ( !VAT.memory[object]['__classes__'] ) {

			VAT.memory[object]['__classes__'] = []

		}

		VAT.memory[object]['__classes__'].push(a_class)

		outputMessages.push(VAT.synonym('I take note.'))

	} else if ( doc.has('^what is #Determiner? . of #Determiner? .') ) {

		var prop = doc.match('^what is #Determiner? [.] of #Determiner? .').text('normal')
		var object = doc.after('^what is #Determiner? . of #Determiner?').text('normal')

		if ( VAT.memory[object] && VAT.memory[object][prop] ) {

			outputMessages.push(VAT.capitalize(VAT.memory[object][prop][0] ) + '.')

		} else {

			outputMessages.push('I don\'t know.')

		}

	} else if ( doc.has('^what are #Determiner? . of #Determiner? .') ) {

		var prop = doc.match('^what are #Determiner? [.] of #Determiner? .').nouns().toSingular().text('normal')
		var object = doc.after('^what are #Determiner? . of #Determiner?').text('normal')

		if ( VAT.memory[object] && VAT.memory[object][prop] ) {

			outputMessages.push(VAT.capitalize(VAT.memory[object][prop].join(' and ')) + '.')

		} else {

			outputMessages.push('I don\'t know.')

		}

	} else if ( doc.has('^what do you know about .') ) {

		var object = doc.after('^what do you know about').text('normal')

		if ( VAT.memory[object] && VAT.memory[object]['__classes__'] ) {

			outputMessages.push(VAT.capitalize(object) + ' is a ' + VAT.memory[object]['__classes__'].join(' and a ') + '.')

		} else {

			outputMessages.push('Nothing.')

		}

	} else if ( doc.has('^what is .') ) {

		var object = doc.after('^what is').text('normal')

		if ( VAT.memory[object] && VAT.memory[object]['__classes__'] ) {

			outputMessages.push(VAT.capitalize(object) + ' is a ' + VAT.memory[object]['__classes__'].join(' and a ') + '.')

		} else {

			outputMessages.push('I don\'t know.')

		}

	} else if ( doc.has('. is .') ) {

		var object = doc.before('is').text('normal')

		var prop = doc.match('. is [.]').text('normal')

		if ( !VAT.memory[object] ) {

			VAT.memory[object] = {}

		}

		if ( VAT.memory[prop] && VAT.memory[prop]['__classes__'] ) {

			if ( !VAT.memory[object][ VAT.memory[prop]['__classes__'][0] ] ) {

				VAT.memory[object][ VAT.memory[prop]['__classes__'][0] ] = []

			}

			VAT.memory[object][ VAT.memory[prop]['__classes__'][0] ].push(prop)

		}

		outputMessages.push(VAT.synonym('I take note.'))

	}

	// Quantity.

	if ( doc.has('#Determiner? . has #Value .') ) {

		var object = doc.match('[.] has #Value').text('normal')
		var prop = doc.match('has #Value [.]').text('normal')
		var count = doc.match('#Value').text('normal')

		if ( !VAT.memory[object] ) {

			VAT.memory[object] = {}

		}

		VAT.memory[object][prop] = count

		outputMessages.push(VAT.synonym('I take note.'))

	} else if ( doc.has('^how many . #Determiner? . has') ) {

		var object = doc.match('[.] has').text('normal')
		var prop = doc.match('many [.]').text('normal')

		outputMessages.push(VAT.capitalize(VAT.memory[object][prop]) + '.')

	}

	// Politeness.

	if ( doc.has('^how are you') ) {

		outputMessages.push('I\'m fine and you?')

	}

	// Mirroring.

	if ( doc.has('^you are #Determiner #Adjective (assistant|bot)') ) {

		var adjective = doc.match('#Adjective').text()

		if ( /^[aeiou]/g.test(adjective) ) {

			outputMessages.push('You are an ' + adjective + ' person.')

		} else {

			outputMessages.push('You are a ' + adjective + ' person.')

		}

	}

	// Capabilities.

	if ( doc.has('^what can you do') || doc.has('^help me?$') ) {

		if ( doc.has('^help me?$') ) {

			outputMessages.push('I can maybe help you.')

		} else {

			outputMessages.push('I can do many things.')

		}

		outputMessages.push('Choose a sentence then customize it: <br> - ' + VAT.capabilities.join('<br> - '))

	}

	if ( doc.has('^open (#Determiner|#Possessive)? SketchUp? (model|file)') ) {

		outputMessages.push(VAT.synonym('OK.'))

		sketchup.openModel()

	} else if ( doc.has('^clean (#Determiner|#Possessive)? SketchUp? model') ) {

		outputMessages.push(VAT.synonym('OK.'))

		sketchup.cleanModel({

			onCompleted: () => { VAT.botSay(VAT.synonym('It\'s done.')) }

		})

	} else if ( doc.has('^select #Determiner? first (object|entity)') ) {

		outputMessages.push(VAT.synonym('OK.'))

		sketchup.selectFirstEntity()

	} else if ( doc.has('^select #Determiner? first group') ) {

		outputMessages.push(VAT.synonym('OK.'))

		sketchup.selectFirstGroup()

	} else if ( doc.has('^select #Determiner? group with name .') ) {

		var name = doc.after('name').text().trim()

		if ( name != '' ) {

			outputMessages.push(VAT.synonym('OK.'))

			sketchup.selectGroupsNamed(name)

		}

	} else if ( doc.has('^select #Determiner? first (instance|component)') ) {

		outputMessages.push(VAT.synonym('OK.'))

		sketchup.selectFirstComponent()

	} else if ( doc.has('^select #Determiner? (instance|component) with name .') ) {

		var name = doc.after('name').text().trim()

		if ( name != '' ) {

			outputMessages.push(VAT.synonym('OK.'))

			sketchup.selectComponentsNamed(name)

		}

	} else if ( doc.has('^move') ) {

		outputMessages.push(VAT.synonym('OK.'))

		sketchup.moveSelection()

	} else if ( doc.has('^rotate by .') ) {

		var angle = doc.match('[#NumericValue] degrees').text()

		if ( angle != '' ) {

			outputMessages.push(VAT.synonym('OK.'))

			sketchup.rotateSelection(angle)

		}

	} else if ( doc.has('^increase size .') ) {

		var scale = doc.match('[#NumericValue] times').text()

		if ( scale != '' ) {

			outputMessages.push(VAT.synonym('OK.'))

			sketchup.scaleSelection(scale)

		}

	} else if ( doc.has('^name .') ) {

		var name = doc.after('name').text().trim()

		if ( name != '' ) {

			outputMessages.push(VAT.synonym('OK.'))

			sketchup.renameSelection(name)

		}

	} else if ( doc.has('^(duplicate|copy) and name .') ) {

		var name = doc.after('name').text().trim()

		if ( name != '' ) {

			outputMessages.push(VAT.synonym('OK.'))

			sketchup.copySelection(name)

		}

	} else if ( doc.has('^clear #Determiner? selection') ) {

		outputMessages.push(VAT.synonym('OK.'))

		sketchup.clearSelection({

			onCompleted: () => { VAT.botSay(VAT.synonym('It\'s done.')) }

		})

	} else if ( doc.has('^(delete|erase)') ) {

		outputMessages.push(VAT.synonym('OK.'))

		sketchup.eraseSelectedEntities()

	} else if ( doc.has('^activate #Determiner? .+ tool') ) {

		outputMessages.push(VAT.synonym('OK.'))

		var action = doc.text('reduced')

		action = action.replace(doc.match('#Determiner').text('reduced'), '')
		action = action.replace(doc.match('please').text('reduced'), '')

		action = action.replace('select', 'selection')
		action = action.replace('eraser', 'erase')
		action = action.replace('paint bucket', 'paint')
		action = action.replace('follow me', 'extrude')
		action = action.replace('tape measure', 'measure')
		action = action.replace('axes', 'axis')
		action = action.replace('dimensions', 'dimension')

		action = action.replace('activate', 'select')
		action = VAT.camelize(action) + ':'

		sketchup.sendAction(action)

	} else if ( doc.has('^draw me? #Determiner? (cube|box)') ) {

		outputMessages.push(VAT.synonym('OK.'))

		sketchup.drawBox()

	} else if ( doc.has('^draw me? #Determiner? cone') ) {

		outputMessages.push(VAT.synonym('OK.'))

		sketchup.drawCone()

	} else if ( doc.has('^draw me? #Determiner? cylinder') ) {

		outputMessages.push(VAT.synonym('OK.'))

		sketchup.drawCylinder()

	} else if ( doc.has('^draw me? #Determiner? prism') ) {

		outputMessages.push(VAT.synonym('OK.'))

		sketchup.drawPrism()

	} else if ( doc.has('^draw me? #Determiner? pyramid') ) {

		outputMessages.push(VAT.synonym('OK.'))

		sketchup.drawPyramid()

	} else if ( doc.has('^draw me? #Determiner? sphere') ) {

		outputMessages.push(VAT.synonym('OK.'))

		sketchup.drawSphere()

	} else if ( doc.has('^write .') ) {

		var text = doc.after('write').text().trim()

		outputMessages.push(VAT.synonym('OK.'))

		sketchup.writeText()

	} else if ( doc.has('^search #Determiner? (extension|plugin) about .') ) {

		outputMessages.push(VAT.synonym('OK.'))

		var topics = doc.after('about').text().trim()

		sketchup.searchPlugin(topics, {

			onCompleted: () => { VAT.botSay(VAT.synonym('It\'s done.')) }

		})

	}

	// Politeness.

	if ( doc.has('(goodbye|bye)') || doc.has('see you') ) {

		sketchup.closeChatRoom()

	}

	if ( doc.has('(thanks|thx)') || doc.has('thank you') ) {

		outputMessages.push(VAT.synonym('You\'re welcome.'))

	}

	// Mirroring.

	if ( doc.has('(yes|perfect|ok|okay|good|well)') ) {

		outputMessages.push('👍')

	}

	if ( inputMessage.trim() == '' ) {

		outputMessages.push('🤔')

	}

	// Output.

	if ( outputMessages.length >= 1 ) {

		VAT.botSay(outputMessages.join(' '))

	} else {

		VAT.botSay('I didn\'t understand... Did you mean: ' + VAT.didYouMean(inputMessage))

	}

}

/**
 * Displays user message.
 *
 * @param {string} message
 *
 * @return {void}
 */
VAT.userSay = message => {

	document.querySelector('#messages').innerHTML += '<div class="message user-message">Me: ' + message + '</div>'

}

/**
 * Displays bot message.
 *
 * @param {string} message
 *
 * @return {void}
 */
VAT.botSay = message => {

	document.querySelector('#messages').innerHTML += '<div class="message bot-message">Bot: ' + message + '</div>'

}

/**
 * Listens to "user say" event.
 *
 * @return {void}
 */
VAT.listenToUserSay = () => {

	document.querySelector('#user-say-button').addEventListener('click', _event => {

		VAT.chatBot(document.querySelector('#user-input').value)

		document.querySelector('#user-input').value = ''

		window.scrollTo(0, document.body.scrollHeight);

	})

	window.setInterval(() => {

		var request = new XMLHttpRequest()

		request.addEventListener('load', event => {

			if ( event.target.status != 200 ) {

				return false;

			}

			var sentence = event.target.response.trim()

			if ( sentence != '' ) {

				VAT.chatBot(VAT.capitalize(sentence) + '.')

				window.scrollTo(0, document.body.scrollHeight);

			}

		})

		request.open('GET', 'http://localhost:8000/readelete-sentence.php')

		request.send();

	}, 1000)

}

// When document is ready:
document.addEventListener('DOMContentLoaded', _event => {

	sketchup.getUserName()

	sketchup.loadMemory({

		onCompleted: VAT.saveMemoryRegularly

	})

	VAT.enableAutoComplete()

	VAT.listenToUserSay()
	
})
