exit
theorem tst (a b : Prop) (H : ¬ a ∨ ¬ b) (Hb : b) : ¬ a ∧ b :=
begin
  apply and.intro,
  assume Ha, or.elim H
    (assume Hna, @absurd _ false Ha Hna)
    (assume Hnb, @absurd _ false Hb Hnb),
  assumption
end