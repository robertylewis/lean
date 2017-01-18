/-
Copyright (c) 2016 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: Leonardo de Moura
-/
prelude
import init.sigma init.meta init.combinator

namespace sigma
section
  variables {A : Type} {B : A → Type}
  variable  (Ra  : A → A → Prop)
  variable  (Rb  : ∀ a, B a → B a → Prop)

  -- Lexicographical order based on Ra and Rb
  inductive lex : sigma B → sigma B → Prop :=
  | left  : ∀ {a₁ : A} (b₁ : B a₁) {a₂ : A} (b₂ : B a₂), Ra a₁ a₂ → lex (sigma.mk a₁ b₁) (sigma.mk a₂ b₂)
  | right : ∀ (a : A)  {b₁ b₂ : B a}, Rb a b₁ b₂ → lex (sigma.mk a b₁)  (sigma.mk a b₂)
end


section
  open ops well_founded tactic
  parameters {A : Type} {B : A → Type}
  parameters {Ra  : A → A → Prop} {Rb : Π a : A, B a → B a → Prop}
  local infix `≺`:50 := lex Ra Rb

  definition lex_accessible {a} (aca : acc Ra a) (acb : ∀a, well_founded (Rb a))
             : ∀ (b : B a), acc (lex Ra Rb) (sigma.mk a b) :=
  acc.rec_on aca
    (λxa aca (iHa : ∀y, Ra y xa → ∀b : B y, acc (lex Ra Rb) (sigma.mk y b)),
      λb : B xa, acc.rec_on (well_founded.apply (acb xa) b)
        (λxb acb
          (iHb : ∀ (y : B xa), Rb xa y xb → acc (lex Ra Rb) (sigma.mk xa y)),
          acc.intro (sigma.mk xa xb) (λp (lt : p ≺ (sigma.mk xa xb)),
            have aux : xa = xa → xb == xb → acc (lex Ra Rb) p, from
              @sigma.lex.rec_on A B Ra Rb (λp₁ p₂, p₂.1 = xa → p₂.2 == xb → acc (lex Ra Rb) p₁)
                                p (sigma.mk xa xb) lt
                (λ (a₁ : A) (b₁ : B a₁) (a₂ : A) (b₂ : B a₂) (H : Ra a₁ a₂) (eq₂ : a₂ = xa) (eq₃ : b₂ == xb),
                  by do
                     /- TODO(Leo): cleanup using quotations -/
                     get_local `eq₂ >>= subst,
                     iHa : expr ← get_local `iHa, a₁ ← get_local `a₁, H ← get_local `H, b₁ ← get_local `b₁,
                     exact (expr.app_of_list iHa [a₁,  H, b₁]))
                (λ (a : A) (b₁ b₂ : B a) (H : Rb a b₁ b₂) (eq₂ : a = xa) (eq₃ : b₂ == xb),
                  by do
                     /- TODO(Leo): cleanup using quotations -/
                    get_local `eq₂ >>= subst,
                    eq₃ ← get_local `eq₃,
                    new_eq₃ ← mk_app `eq_of_heq [eq₃],
                    note `new_eq₃ new_eq₃,
                    get_local `new_eq₃ >>= subst,
                    iHb : expr ← get_local `iHb, b₁ ← get_local `b₁, H ← get_local `H,
                    exact (expr.app_of_list iHb [b₁, H])),
                   -- begin cases eq₂, cases eq₃, exact (iHb b₁ H) end),
            aux rfl (heq.refl xb))))

  -- The lexicographical order of well founded relations is well-founded
  definition lex_wf (Ha : well_founded Ra) (Hb : ∀ x, well_founded (Rb x)) : well_founded (lex Ra Rb) :=
  well_founded.intro (λp, destruct p (λa b, lex_accessible (well_founded.apply Ha a) Hb b))

end
end sigma