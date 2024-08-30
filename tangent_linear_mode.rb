class AutoFloat
  attr_reader :value, :tangent

  def initialize(value, tangent = 0.0)
    @value = value
    @tangent = tangent
  end

  def+(other) # AutoFloat + AutoFloat
    new_value = @value + other.value
    new_tangent = @tangent + other.tangent
    AutoFloat.new(new_value, new_tangent)
  end

  def-(other) # AutoFloat - AutoFloat
    new_value = @value - other.value
    new_tangent = @tangent - other.tangent
    AutoFloat.new(new_value, new_tangent)
  end

  def *(other) # AutoFloat * AutoFloat
    new_value = @value * other.value
    new_tangent = @tangent * other.value + @value * other.tangent
    AutoFloat.new(new_value, new_tangent)
  end

  def **(other) # AutoFloat ** c
    new_value = @value ** other
    new_tangent = other * (@value ** other) * (1/@value) * @tangent
    AutoFloat.new(new_value, new_tangent)
  end

  def sqrt # sqrt(AutoFloat)
    new_value = Math.sqrt(@value)
    new_tangent = 0.5 * @tangent / new_value
    AutoFloat.new(new_value, new_tangent)
  end

  def exp # exp(AutoFloat)
    new_value = Math.exp(@value)
    new_tangent = new_value * @tangent
    AutoFloat.new(new_value, new_tangent)
  end

  def log # log(AutoFloat)
    new_value = Math.log(@value)
    new_tangent = @tangent / @value
    AutoFloat.new(new_value, new_tangent)
  end

  def sin # sin(AutoFloat)
    new_value = Math.sin(@value)
    new_tangent = Math.cos(@value) * @tangent
    AutoFloat.new(new_value, new_tangent)
  end

  def cos # cos(AutoFloat)
    new_value = Math.cos(@value)
    new_tangent = -1 * Math.sin(@value) * @tangent
    AutoFloat.new(new_value, new_tangent)
  end
end

# scalar-valued function y(x1, x2) = x1 + x1 * x2
# tangent y = partial{y}/partial{x1}
# x1 = 3, x2 = 5일 때 x1에 대한 y의 derivative는...
x1 = AutoFloat.new(3, 1)
x2 = AutoFloat.new(5)
y = x1 + x1 * x2
p y

# scalar-valued function y(x1, x2, x3) = x1 + cos(x1) * sin(x2) * log(x3)
# tangent y = partial{y}/partial{x1}
# x1 = 3, x2 = 5, x3 = 7일 때 x1에 대한 y의 derivative는...
x1 = AutoFloat.new(3.0)
x2 = AutoFloat.new(5.0)
x3 = AutoFloat.new(7.0, 1.0)
y = x1 + x1.cos * x2.sin * x3.log
p y