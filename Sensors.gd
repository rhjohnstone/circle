extends Node

var JavaScript = JavaScriptBridge
func _init():
	
	if !OS.has_feature('web'): pass
	JavaScript.eval("""
		var acceleration = { x: 0, y: 0, z: 0 }

		function registerMotionListener() {
			window.ondevicemotion = function(event) {
				if (event.accelerationIncludingGravity.x === null) return
				acceleration.x = event.accelerationIncludingGravity.x
				acceleration.y = event.accelerationIncludingGravity.y
				acceleration.z = event.accelerationIncludingGravity.z
			}
		}

		if (typeof DeviceOrientationEvent.requestPermission === 'function') {
			DeviceOrientationEvent.requestPermission().then(function(state) {
				if (state === 'granted') registerMotionListener()
			})
		}
		else {
			registerMotionListener()
		}
	""", true)

func get_accelerometer() -> Vector3:
	if !OS.has_feature('web'): return Input.get_accelerometer()
	
	var x = JavaScript.eval('acceleration.x')
	var y = JavaScript.eval('acceleration.y')
	var z = JavaScript.eval('acceleration.z')
	return Vector3(x, y, z)
