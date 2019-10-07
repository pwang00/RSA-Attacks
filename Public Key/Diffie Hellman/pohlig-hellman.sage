# Sage already comes built-in with a discrete logarithm function that uses a Pohlig-Hellman / BSGS backend. 
# However, it can never hurt to implement the algorithm yourself for sake of understanding.

def generate_params(B=2^24, num_factors=15):
	""" Generates the public and private parameters for Diffie-Hellman """

	# Generates num_factors primes and multiplies them together to form a modulus 
	p = 1

	# Currently the best way I can think of to generate primes p such that p - 1 is B-smooth
	while not is_prime(p):
		p = 2 * prod([random_prime(B, proof=False) for i in range(num_factors)]) + 1

	F = GF(p)
	g, a, b = [F(randint(0, p)) for i in range(3)]

	A, B = g^a, g^b
	
	assert A^b == B^a and gcd(g, p - 1) == 1
	return g, A, B, F

# The Pohlig-Hellman attack on Diffie-Hellman works as such:
# Given the generator, public keys of Alice and Bob, as well as the multiplicative order
# Of the group, one can factor the group order (which by construction here is B-smooth) into 
# Small primes.  

def pohlig_hellman(g, A, F):
	""" Attempts to use Pohlig-Hellman to compute discrete logarithm of A = g^a mod p"""
	
	p = F.order() 
	factors = factor(F.order() - 1)

	crt_array = []

	for p_i, e_i in factors:
		g_i = g ^ ((p - 1) // p_i ^ e_i)
		h_i = A ^ ((p - 1) // p_i ^ e_i)
		for x_i in range(0, p_i^e_i):
			if g_i ^ x_i == h_i:
				crt_array += [x_i]
	factors = [p_i ^ e_i for (p_i, e_i) in factors]
	return crt(crt_array, factors)

def test():
	g, A, B, F = generate_params()
	a = pohlig_hellman(g, A, B, F)
	assert g^a == A
	print("[x] Recovered exponent a through Pohlig-Hellman: %d" % a)

if __name__ == "__main__":
	test()


