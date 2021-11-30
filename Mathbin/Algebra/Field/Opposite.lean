import Mathbin.Algebra.Field.Basic 
import Mathbin.Algebra.Ring.Opposite

/-!
# Field structure on the multiplicative opposite
-/


variable (α : Type _)

namespace MulOpposite

instance [DivisionRing α] : DivisionRing («expr ᵐᵒᵖ» α) :=
  { MulOpposite.groupWithZero α, MulOpposite.ring α with  }

instance [Field α] : Field («expr ᵐᵒᵖ» α) :=
  { MulOpposite.divisionRing α, MulOpposite.commRing α with  }

end MulOpposite

