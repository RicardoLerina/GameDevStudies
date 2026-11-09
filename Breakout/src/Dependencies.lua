-- Every module is required from this one file, so main.lua stays short and
-- the load order is defined in a single place.

push = require 'lib.push'
Class = require 'lib.class'

require 'src.constants'

require 'src.Ball'
require 'src.Brick'
require 'src.LevelMaker'
require 'src.Paddle'
require 'src.StateMachine'
require 'src.Util'

-- BaseState must come before the other states, since they inherit from it.
require 'src.states.BaseState'
require 'src.states.EnterHighScoreState'
require 'src.states.GameOverState'
require 'src.states.HighScoreState'
require 'src.states.PaddleSelectState'
require 'src.states.PlayState'
require 'src.states.ServeState'
require 'src.states.StartState'
require 'src.states.VictoryState'
