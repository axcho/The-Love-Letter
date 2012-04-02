package org.flixel.plugin.axcho 
{
	import flash.utils.Dictionary;
	import org.flixel.FlxG;
	import org.flixel.FlxU;
	
	/**
	 * ...
	 * @author axcho
	 */
	public class FlxScript
	{
		
		static public const none:Object = null;
		static public const yes:Boolean = true;
		static public const no:Boolean = false;
		
		static public function not(Expression:Boolean):Boolean
		{
			// return logical not for script
			return (!Expression);
		}
		
		static public function both(Expression1:Boolean, Expression2:Boolean):Boolean
		{
			// return logical and for script
			return (Expression1 && Expression2);
		}
		
		static public function either(Expression1:Boolean, Expression2:Boolean):Boolean
		{
			// return logical or for script
			return (Expression1 || Expression2);
		}
		
		static public function equal(Expression1:Object, Expression2:Object):Boolean
		{
			// return equality for script
			return (Expression1 == Expression2);
		}
		
		static public function bigger(Expression1:Number, Expression2:Number):Boolean
		{
			// return equality for script
			return (Expression1 > Expression2);
		}
		
		static public function smaller(Expression1:Number, Expression2:Number):Boolean
		{
			// return equality for script
			return (Expression1 < Expression2);
		}
		
		static public function change(Parent:Object, Property:String, Value:*):void
		{
			// set property of parent to value for script
			Parent[Property] = Value;
		}
		
		static public function get manager():ScriptManager
		{
			// get the script manager
			var scriptManager:ScriptManager = FlxG.getPlugin(ScriptManager) as ScriptManager;
			
			// if the manager does not exist
			if (!scriptManager)
			{
				// create a new script manager
				scriptManager = new ScriptManager();
				
				// add it
				FlxG.addPlugin(scriptManager);
			}
			
			// return the script manager
			return scriptManager;
		}
		
		public var actors:Array;
		public var delay:Number;
		public var paused:Boolean;
		
		protected const COLON:String = ":";
		protected const EXCLAMATION_MARK:String = "!";
		protected const QUESTION_MARK:String = "?";
		protected const ELLIPSIS:String = "...";
		protected const COMMA:String = ",";
		protected const QUOTE:String = "\"";
		protected const APOSTROPHE:String = "'";
		
		protected var _events:Array;
		protected var _statesByName:Dictionary;
		protected var _startingStateName:String;
		
		public function FlxScript(ScriptData:* = null, Actors:Array = null)
		{
			super();
			actors = (Actors) ? Actors : [this];
			delay = 1.0;
			paused = false;
			
			// create an empty script
			clear();
			
			// if the script data is specified
			if (ScriptData != null)
			{
				// load the script data
				loadScript(ScriptData);
			}
		}
		
		public function destroy():void
		{
			// stop the script
			stop();
			
			// remove all actors
			actors = null;
			
			// remove all events
			_events = null;
			
			// remove all states
			_statesByName = null;
			
			// remove the starting state name
			_startingStateName = null;
		}
		
		public function update():void
		{
			// possibly switch to a new state
			var newStateName:String = null;
			
			// for each event
			for (var i:String in _events)
			{
				// get the event
				var event:FlxEvent = _events[i];
				
				// get the actions list
				var actions:Array = event.actions;
				
				// get the timer
				var timer:Number = event.timer;
				
				// get the index
				var index:uint = event.index;
				
				// if the timer is running
				if (timer > 0)
				{
					// advance the timer
					timer -= FlxG.elapsed;
				}
				
				// if the timer is finished
				if (timer <= 0)
				{
					// reset the timer
					timer = 0;
					
					// if the index is past the end of the actions list
					if (index >= actions.length)
					{
						// reset the index
						index = 0;
					}
					
					// while index is within range and timer is not running
					while (index < actions.length && timer <= 0)
					{
						// get the action at the index
						var action:Array = actions[index];
						
						// if the action has only one token and the token is an ellipsis
						if (action.length == 1 && action[0] == ELLIPSIS)
						{
							// add a delay to the current timer
							timer += delay;
						}
						// if the action has only one token and the token is a state name
						else if (action.length == 1 && _statesByName.hasOwnProperty(action[0]))
						{
							// switch to the new state later
							newStateName = action[0];
							
							// stop on this action
							break;
						}
						// interpret the action
						else if (!interpretAction(action))
						{
							// stop on this action
							break;
						}
						
						// go to the next action
						index++;
					}
				}
				
				// save the new event timer
				event.timer = timer;
				
				// save the new event index
				event.index = index;
			}
			
			// if there is a new state to switch to
			if (newStateName)
			{
				// switch to the new state
				switchState(newStateName);
			}
		}
		
		public function clear():void
		{
			// reset all events
			_events = new Array();
			
			// reset all states
			_statesByName = new Dictionary();
			
			// reset the starting state
			_startingStateName = "";
		}
		
		public function start():FlxScript
		{
			// add this to the script manager
			manager.add(this);
			
			// if not paused
			if (!paused)
			{
				// switch to the starting state
				switchState(_startingStateName);
			}
			
			// not paused
			paused = false;
			
			// return this for chaining
			return this;
		}
		
		public function stop():void
		{
			// remove this from the script manager
			manager.remove(this);
		}
		
		public function loadScript(ScriptData:*):FlxScript
		{
			// get the script data as a string
			var scriptString:String;
			
			// if script data is a file
			if (ScriptData is Class)
			{
				// convert it to a string
				scriptString = (new ScriptData()).toString();
			}
			// if script data is a string
			else if (ScriptData is String)
			{
				// save it as the script string
				scriptString = ScriptData as String;
			}
			else
			{
				// covert it to a string
				scriptString = ScriptData.toString();
			}
			
			// split the string into lines
			var lines:Array = scriptString.split(/\s*\n\s*/);
			
			// create a list of state names
			var stateNames:Array = [_startingStateName];
			
			// create a list of events
			var events:Array = new Array();
			
			// create a list of actions
			var actions:Array = new Array();
			
			// for each line
			var lineTotal:uint = lines.length;
			for (var i:uint = 0; i < lineTotal; i++)
			{
				// create an array for the action
				var action:Array = new Array();
				
				// get the line
				var line:String = lines[i];
				
				// split the line into sections on quotes
				var sections:Array = line.split(QUOTE);
				
				// alternate quoted and non-quoted sections
				var quoted:Boolean = false;
				
				// for each section
				var sectionTotal:uint = sections.length;
				for (var s:uint = 0; s < sectionTotal; s++)
				{
					// get the section
					var section:String = sections[s];
					
					// if this is a quoted section
					if (quoted)
					{
						// add the whole section to the action
						action.push(QUOTE + section + QUOTE);
					}
					else
					{
						// break the section into tokens
						var tokens:Array = section.split(/\s+/);
						
						// for each token
						var tokenTotal:uint = tokens.length;
						for (var t:uint = 0; t < tokenTotal; t++)
						{
							// get the token
							var token:String = tokens[t];
							
							// skip if the token is empty
							if (token.length <= 0) continue;
							
							// if the token starts with an apostrophe
							if (token.indexOf(APOSTROPHE) == 0)
							{
								// skip to the next line
								s = sectionTotal;
								t = tokenTotal;
								break;
							}
							
							// look for ending punctuation marks
							var marks:Array = [COLON, EXCLAMATION_MARK, QUESTION_MARK, COMMA];
							
							// for each ending punctuation mark
							for (var m:String in marks)
							{
								// get the punctuation mark
								var mark:String = marks[m];
								
								// if the token ends in the punctuation mark
								if (token.lastIndexOf(mark) == token.length - 1)
								{
									// remove the punctuation mark
									token = token.substr(0, token.length - 1);
									
									// if the token is not empty
									if (token.length > 0)
									{
										// add the token
										action.push(token);
									}
									
									// add the punctuation mark next
									token = mark;
									
									// stop looking for punctuation marks
									break;
								}
							}
							
							// add the token to the action
							action.push(token);
						}
					}
					
					// reverse quoted
					quoted = !quoted;
				}
				
				// continue to the next line if the action is empty
				if (action.length <= 0) continue;
				
				// check whether this is the start of an event
				var eventStart:Boolean = (action.indexOf(EXCLAMATION_MARK) >= 0);
				
				// check whether this is the start of a state
				var stateStart:Boolean = (action.indexOf(COLON) >= 0);
				
				// if this is the start of an event or a state
				if (eventStart || stateStart)
				{
					// if the list of actions is not empty
					if (actions.length > 0)
					{
						// add a new event to the list
						events.push(new FlxEvent(actions));
						
						// create a new list of actions
						actions = new Array();
					}
					
					// if this is the start of a state
					if (stateStart)
					{
						// add the events to the active states
						addEventsToStates(events, stateNames);
						
						// create a new list of events
						events = new Array();
						
						// create a new list of state names
						stateNames = new Array();
						
						// for each token in the action
						tokenTotal = action.length;
						for (t = 0; t < tokenTotal; t++)
						{
							// get the token
							token = action[t];
							
							// if the token is not a reserved token
							if (token != COLON &&
								token != EXCLAMATION_MARK &&
								token != QUESTION_MARK &&
								token != ELLIPSIS &&
								token != COMMA)
							{
								// if the token is not already in the list
								if (stateNames.indexOf(token) < 0)
								{
									// add the token as a state name
									stateNames.push(token);
								}
							}
						}
						
						// continue to the next line without adding this action
						continue;
					}
				}
				
				// add the action to the current list
				actions.push(action);
			}
			
			// if the last list of actions is not empty
			if (actions.length > 0)
			{
				// add a new event to the list
				events.push(new FlxEvent(actions));
			}
			
			// add the events to state names
			addEventsToStates(events, stateNames);
			
			// return this for chaining
			return this;
		}
		
		protected function switchState(StateName:String):void
		{
			// if the state name exists
			if (StateName != null)
			{
				// get the events from the state
				_events = _statesByName[StateName];
			}
			
			// for each event
			for (var i:String in _events)
			{
				// get the event
				var event:FlxEvent = _events[i];
				
				// reset the timer
				event.timer = 0.0;
				
				// reset the index
				event.index = 0;
			}
		}
		
		protected function addEventsToStates(Events:Array, StateNames:Array):void
		{
			// for each state name
			for (var i:String in StateNames)
			{
				// get the state name
				var stateName:String = StateNames[i];
				
				// get the old list of events for the state name
				var oldEvents:Array = _statesByName[stateName];
				
				// if the old list of events does not exist
				if (!oldEvents)
				{
					// assign the new list of events to the state name
					_statesByName[stateName] = Events;
				}
				else
				{
					// append the new list of events to the old list
					_statesByName[stateName] = oldEvents.concat(Events);
				}
				
				// if the starting state does not exist or is empty
				if (!_startingStateName || _startingStateName.length <= 0)
				{
					// get the list of events for the starting state
					var startingEvents:Array = _statesByName[_startingStateName];
					
					// if there are no events for the starting state
					if (!startingEvents || startingEvents.length <= 0)
					{
						// save this state name as the starting state
						_startingStateName = stateName;
					}
				}
			}
		}
		
		protected function interpretAction(Action:Array):Boolean 
		{
			// continue to the next action no matter what
			var continueNoMatterWhat:Boolean = true;
			
			// continue to the next action if there are no parameters
			var continueWithNoParameters:Boolean = true;
			
			// save the objects and functions found
			var object:* = undefined;
			var functionObject:Function = null;
			var functionParameters:Array = new Array();
			var functionObjectStack:Array = new Array();
			var functionParametersStack:Array = new Array();
			
			// for each token in the action
			var i:uint = 0;
			var tokenTotal:uint = Action.length;
			while (i < tokenTotal)
			{
				// get the token
				var token:String = Action[i];
				
				// if the token is an exclamation mark or a question mark
				if (token == EXCLAMATION_MARK || token == QUESTION_MARK)
				{
					// continue to the next line only conditionally
					continueNoMatterWhat = false;
					
					// if the token is a question mark
					if (token == QUESTION_MARK)
					{
						// do not continue to the next line if there are no parameters
						continueWithNoParameters = false;
					}
					
					// if object is defined
					if (object !== undefined)
					{
						// save the object as a parameter
						functionParameters.push(object);
						
						// reset the object
						object = undefined;
					}
					
					// while function object exists
					while (functionObject != null)
					{
						// call the function and save the result as the object
						object = functionObject.apply(null, functionParameters);
						
						// pop the last function from the stack
						functionObject = functionObjectStack.pop();
						functionParameters = functionParametersStack.pop();
						
						// if object is defined
						if (object !== undefined)
						{
							// save the object as a parameter
							functionParameters.push(object);
						}
					}
				}
				// if the token is a comma
				else if (token == COMMA)
				{
					// if the old object is defined
					if (object !== undefined)
					{
						// save the old object as a parameter
						functionParameters.push(object);
						
						// reset the object
						object = undefined;
						
						// if function object exists
						if (functionObject != null)
						{
							// if function has enough parameters
							if (functionParameters.length == functionObject.length)
							{
								// call the function and save the result as the object
								object = functionObject.apply(null, functionParameters);
								
								// pop the last function from the stack
								functionObject = functionObjectStack.pop();
								functionParameters = functionParametersStack.pop();
							}
						}
					}
					// if function object exists
					else if (functionObject != null)
					{
						// call the function and save the result as the object
						object = functionObject.apply(null, functionParameters);
						
						// pop the last function from the stack
						functionObject = functionObjectStack.pop();
						functionParameters = functionParametersStack.pop();
					}
				}
				// if the token is something else
				else
				{
					// get the value of the token
					var value:* = parseToken(token, object);
					
					// if the value is undefined
					if (value === undefined)
					{
						// if the old object is defined
						if (object !== undefined)
						{
							// save the old object as a parameter
							functionParameters.push(object);
							
							// reset the object
							object = undefined;
							
							// if function object exists
							if (functionObject != null)
							{
								// if function has enough parameters
								if (functionParameters.length == functionObject.length)
								{
									// call the function and save the result as the object
									object = functionObject.apply(null, functionParameters);
									
									// pop the last function from the stack
									functionObject = functionObjectStack.pop();
									functionParameters = functionParametersStack.pop();
								}
							}
							
							// parse the token again
							continue;
						}
						// if the old object is undefined and game is running in debug mode
						else if (FlxG.debug)
						{
							// log a warning message that the token is undefined
							FlxG.log("WARNING: undefined token '" + token + "'");
						}
					}
					// if the value is a function
					else if (value is Function)
					{
						// save the old function object
						functionObjectStack.push(functionObject);
						functionParametersStack.push(functionParameters);
						
						// save the value as the new function object
						functionObject = value;
						functionParameters = new Array();
						
						// reset the object
						object = undefined;
					}
					// if the value is an object
					else if (value is Object)
					{
						// save it as the new object
						object = value;
					}
				}
				
				// next token
				i++;
			}
			
			// if object is defined
			if (object !== undefined)
			{
				// save the object as a parameter
				functionParameters.push(object);
				
				// reset the object
				object = undefined;
			}
			
			// while function object exists
			while (functionObject != null)
			{
				// call the function and save the result as the object
				object = functionObject.apply(null, functionParameters);
				
				// pop the last function from the stack
				functionObject = functionObjectStack.pop();
				functionParameters = functionParametersStack.pop();
				
				// save the object as a parameter
				functionParameters.push(object);
			}
			
			// if should not continue no matter what
			if (!continueNoMatterWhat)
			{
				// if there are no parameters
				if (functionParameters.length == 0)
				{
					// continue if should continue even with no parameters
					return continueWithNoParameters;
				}
				
				// for each remaining parameter
				i = functionParameters.length;
				while (i--)
				{
					// get the parameter
					var parameter:Boolean = Boolean(functionParameters[i]);
					
					// if the parameter is not true
					if (!parameter)
					{
						// do not continue to the next action
						return false;
					}
				}
			}
			
			// continue to the next action
			return true;
		}
		
		protected function parseToken(Token:String, Parent:Object = null):*
		{
			// if the parent exists
			if (Parent != null)
			{
				// if the token is a property of the parent
				if (Parent.hasOwnProperty(Token))
				{
					// return the token as a property
					return Parent[Token];
				}
			}
			// if parent does not exist
			else
			{
				// if token starts with a quote
				if (Token.indexOf(QUOTE) == 0)
				{
					// return the token as a string without quotes
					var tokenString:String = Token.substr(1, Token.length - 2);
					return tokenString;
				}
				
				// try to parse the token as a number
				var tokenNumber:Number = Number(Token);
				
				// if token is a valid number
				if (!isNaN(tokenNumber))
				{
					// return the token as a number
					return tokenNumber;
				}
				
				// for each actor
				var actorTotal:uint = actors.length;
				for (var a:uint = 0; a < actorTotal; a++)
				{
					// set the parent to the actor
					Parent = actors[a];
					
					// if the token is a property of the parent
					if (Parent.hasOwnProperty(Token))
					{
						// return the token as a property
						return Parent[Token];
					}
					
					// if the parent is a class
					if (Parent is Class)
					{
						// if the token is the class name of the parent
						if (Token == FlxU.getClassName(Parent, true))
						{
							// return the token as the class
							return Parent;
						}
					}
					// if the parent is not a class
					else
					{
						// get the class of the parent
						Parent = Parent.constructor;
						
						// if the token is a property of the parent
						if (Parent.hasOwnProperty(Token))
						{
							// return the token as a property
							return Parent[Token];
						}
					}
				}
			}
			
			// otherwise just return undefined
			return undefined;
		}
		
	}
	
}

/**
 * ...
 * @author axcho
 */
internal class FlxEvent
{
	
	public var actions:Array;
	public var timer:Number;
	public var index:uint;
	
	public function FlxEvent(Actions:Array)
	{
		// create a new event with the given actions
		actions = Actions;
		timer = 0.0;
		index = 0;
	}
	
}