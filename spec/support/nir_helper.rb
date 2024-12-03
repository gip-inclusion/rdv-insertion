module NirHelper
  def generate_random_nir(sex: :male)
    # choosing random male born in 80
    base_nir = "#{sex == :male ? 1 : 2}80#{10.times.map { rand(1..9) }.join}"
    NirHelper.format_nir(base_nir)
  end
end
