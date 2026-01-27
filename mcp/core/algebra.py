import math

class OrbitAlgebra:
    """
    Implementation of the SYMBIOTIC ALGEBRA for Orbit-DevOps.
    """
    
    @staticmethod
    def calculate_vitality(omega: float, phi: float, sigma: float, efficiency_exponent: float = 1.2) -> float:
        """
        Algebraic Formula: Va = (Phi / (Omega + 1)) * (Sigma ^ e)
        """
        if sigma <= 0:
            return 0.0
            
        return (phi / (omega + 1.0)) * math.pow(sigma, efficiency_exponent)

    @staticmethod
    def reason_state(omega: float, phi: float, sigma: float) -> dict:
        """
        Analyzes the system state vector and recommends algebraic operators.
        """
        va = OrbitAlgebra.calculate_vitality(omega, phi, sigma)
        
        analysis = {
            "vitality_score": round(va, 4),
            "state_vector": [omega, phi, sigma],
            "recommendation": "STABLE_ORBIT",
            "proof": ""
        }
        
        if omega > 0.6:
            analysis["recommendation"] = "OPERATOR_CLEANUP (C)"
            analysis["proof"] = "Proof: Omega > 0.6 violates entropy threshold (Axioma da Ordem)."
        elif phi < 0.4:
            analysis["recommendation"] = "OPERATOR_MUTATION (M)"
            analysis["proof"] = "Proof: Phi < 0.4 requires Scaled DNA Mutation to maintain homeostasis."
        elif sigma < 0.5:
            analysis["recommendation"] = "OPERATOR_MUTATION (M)"
            analysis["proof"] = "Proof: Sigma < 0.5 indicates Symbiotic Friction. DNA realignement required."
            
        return analysis
