module NirHelper
  def generate_random_nir
    loop do
      # choosing random male born in 80
      base = "180#{10.times.map { rand(1..9) }.join}"
      # we concatenate key calculation. Can be < 10, that is why we loop, to be sure
      # to have a 15 digits nir
      nir = base + (97 - (base.to_i % 97)).to_s
      break nir if nir.length == 15
    end
  end
end
