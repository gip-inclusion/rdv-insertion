module ServiceSpecHelper
  def is_a_failure
    expect(subject.success?).to eq(false)
    expect(subject.failure?).to eq(true)
  end

  def is_a_success
    expect(subject.success?).to eq(true)
    expect(subject.failure?).to eq(false)
  end
end
