module NirHelper
  def generate_random_nir
    # choosing random male born in 80
    base_nir = "180#{10.times.map { rand(1..9) }.join}"
    NirHelper.format_nir(base_nir)
  end
end
