import math

class vec3:
	def __init__(self):
		self.x = 0;
		self.y = 0;
		self.z = 0;
	
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
	def __init__(self):
		self.pos = vec3()
		self.vel = vec3()
		self.acc = vec3()
		self.mass = 1

	def applyVelocity(self, dt):
		self.pos = self.pos + self.vel * dt
	
	def applyAcceleration(self, dt)
		self.vel = self.vel + self.acc * dt
		
	def applyGravity(self, otherBodies):
		self.acc = 0
		for other in otherBodies:
			# F = ma
			# Fg = r_norm * G(Mm)/|r|^2
			# Fg = r * G (M*m) / |r|^3
			# F = ma --> a = f/m
			# a = r * G * m / |r|^3
			rad = other.pos - self.pos
			self.acc += rad * other.mass / magnitude(rad)**3	
class nbody:

	def __init__(self):
		self.dt = 0.1
		self.bodies = []
		
	def step(self):
		for key, body in bodies:
			#compute gravity before moving things!
			body.applyGravity(bodies)
			
		for body in bodies:
			body.applyAcceleration(self.dt)
			body.applyVelocity(self.dt)
		
		self.score -= sim.score() * self.dt;
	
	def addBody(self, pos, vel):
		
	
	# specific to AutoExperiment toy problem
	
	
	
	
	
		


sim = nbody()

for param in params:
	#set the initial velocity of one of the bodies.
	
	
for i in range(1,100000):
	sim.step()
