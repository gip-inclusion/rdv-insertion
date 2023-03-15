module NirHelper
  def generate_fake_nir
    base = 13.times.map { rand(1..9) }.join
    base + (97 - (base.to_i % 97)).to_s
  end
end
