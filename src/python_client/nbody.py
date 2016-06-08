import math

class vec3:
	def __init__(self, x=0,y=0,z=0):
		self.x = x
		self.y = y
		self.z = z
	
	def __add__(self, other):
		res = vec3()
		res.x = self.x + other.x
		res.y = self.y + other.y
		res.z = self.z + other.z
		return res
	
	def __sub__(self, other):
		res = vec3()
		res.x = self.x - other.x
		res.y = self.y - other.y
		res.z = self.z - other.z
		return res
	
	def __mul__(self, other):
		res = vec3()
		res.x = self.x*other;
		res.y = self.y*other;
		res.z = self.z*other;
		return res;
	
	def __div__(self, other):
		res = vec3()
		res.x = self.x/other;
		res.y = self.y/other;
		res.z = self.z/other;
		return res;
	
	def magnitude(self):
		return math.sqrt(self.x * self.x + self.y*self.y + self.z*self.z)
		
class body:

	def __init__(self, pos=vec3(), vel=vec3(), mas=vec3()):
		self.pos = pos
		self.vel = vel
		self.acc = vec3()
		self.mas = mas

	def applyVelocity(self, dt):
		self.pos = self.pos + self.vel * dt
	
	def applyAcceleration(self, dt):
		self.vel = self.vel + self.acc * dt
		
	def applyGravity(self, otherBodies):
		self.acc = vec3()
		for other in otherBodies:
			if other is not self:
			# F = ma
			# Fg = r_norm * G(Mm)/|r|^2
			# Fg = r * G (M*m) / |r|^3
			# F = ma --> a = f/m
			# a = r * G * m / |r|^3
				rad = other.pos - self.pos
				#print(self.pos.x, other.pos.x)
				self.acc = self.acc + rad * other.mas / rad.magnitude()**3	

class nbody:
	def __init__(self):
		self.dt = 0.1
		self.bodies = []
		self.initialDistance = {}
		
	def step(self):
		for body in self.bodies:
			#compute gravity before moving things!
			body.applyGravity(self.bodies)
			
		for body in self.bodies:
			body.applyAcceleration(self.dt)
			body.applyVelocity(self.dt)

	
	def addBody(self, pos, vel, mas):
		b = body(pos, vel, mas)
		self.bodies.append(b)
		# keep track of how far this object is from each other object.
		self.initialDistance[b] = {other:(b.pos-other.pos).magnitude() for other in self.initialDistance}
		
	
	# specific to AutoExperiment toy problem
	def score(self):

		totalDiff = 0

		for body, distances in self.initialDistance.items():
			for other, initialDistance in distances.items():
				dist = (body.pos - other.pos).magnitude()
				totalDiff = abs(dist - initialDistance)
		
		# The goal of our toy problem is to achieve stable orbits.
		# Any deviation from the initial distances is bad.
		return -totalDiff * self.dt # Scale score wrt to step size. Allows mid-experiment step size shenanigans.
	
	
	
		

def main(parameterData):
	sim = nbody()

	vel = {}

	# should be in loop. meh. demo.
	vel[1] = vec3(parameterData["1.VX"], parameterData["1.VY"], parameterData["1.VZ"])
	vel[2] = vec3(parameterData["2.VX"], parameterData["2.VY"], parameterData["2.VZ"])
	vel[3] = vec3(parameterData["3.VX"], parameterData["3.VY"], parameterData["3.VZ"])
	vel[4] = vec3(parameterData["4.VX"], parameterData["4.VY"], parameterData["4.VZ"])
	vel[5] = vec3(parameterData["5.VX"], parameterData["5.VY"], parameterData["5.VZ"])


	rad = 5
	for i in range(1,5):
		fraction = (i/5.0)*2*math.pi
		pos = vec3(math.cos(fraction), math.sin(fraction), 0) * rad
		mas = 100 #cause quick experiments
		sim.addBody(pos, vel[i], mas)
	
	
	score = 0	
	for i in range(1,10000):
		sim.step()
		score += sim.score()
	return score
