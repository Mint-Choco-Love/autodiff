$global_idx = 0

$forward_value = {}
$forward_dependent = {}
$c = {}

$backward_adjoint = {}

def insert_dependent(indep, dep)
  $forward_dependent[indep] = [] if $forward_dependent[indep].nil?
  $forward_dependent[indep] << dep
end

def add_c(indep, dep, val)
  $c[indep] = {} if $c[indep].nil?
  $c[indep][dep] = 0 if $c[indep][dep].nil?
  $c[indep][dep] += val
end

class AutoFloat
  attr_reader :value, :idx

  def initialize(value)
    $global_idx += 1
    @value = value
    @idx = $global_idx
    $forward_value[@idx] = @value
  end

  def unary_forward(new_value, new_value_idx)
    $forward_value[new_value_idx] = new_value
    insert_dependent(@idx, new_value_idx)
  end

  def binary_forward(other_idx, new_value, new_value_idx)
    $forward_value[new_value_idx] = new_value
    insert_dependent(@idx, new_value_idx)
    insert_dependent(other_idx, new_value_idx)
  end

  def +(other)
    new_value = @value + other.value
    new_autofloat = AutoFloat.new(new_value)

    binary_forward(other.idx, new_value, new_autofloat.idx)

    add_c(@idx, new_autofloat.idx, 1)
    add_c(other.idx, new_autofloat.idx, 1)

    new_autofloat
  end

  def -(other)
    new_value = @value - other.value
    new_autofloat = AutoFloat.new(new_value)

    binary_forward(other.idx, new_value, new_autofloat.idx)

    add_c(@idx, new_autofloat.idx, 1)
    add_c(other.idx, new_autofloat.idx, -1)

    new_autofloat
  end

  def *(other)
    new_value = @value * other.value
    new_autofloat = AutoFloat.new(new_value)

    binary_forward(other.idx, new_value, new_autofloat.idx)

    add_c(@idx, new_autofloat.idx, other.value)
    add_c(other.idx, new_autofloat.idx, @value)

    new_autofloat
  end

  def /(other)
    new_value = @value / other.value
    new_autofloat = AutoFloat.new(new_value)

    binary_forward(other.idx, new_value, new_autofloat.idx)

    add_c(@idx, new_autofloat.idx, 1 / other.value)
    add_c(other.idx, new_autofloat.idx, 1 / @value)

    new_autofloat
  end

  def sqrt
    new_value = Math.sqrt(@value)
    new_autofloat = AutoFloat.new(new_value)

    unary_forward(new_value, new_autofloat.idx)

    add_c(@idx, new_autofloat.idx, 1 / (2 * new_value))

    new_autofloat
  end

  def exp
    new_value = Math.exp(@value)
    new_autofloat = AutoFloat.new(new_value)

    unary_forward(new_value, new_autofloat.idx)

    add_c(@idx, new_autofloat.idx, new_value)

    new_autofloat
  end

  def log
    new_value = Math.log(@value)
    new_autofloat = AutoFloat.new(new_value)

    unary_forward(new_value, new_autofloat.idx)

    add_c(@idx, new_autofloat.idx, 1 / @value)

    new_autofloat
  end

  def cos
    new_value = Math.cos(@value)
    new_autofloat = AutoFloat.new(new_value)

    unary_forward(new_value, new_autofloat.idx)

    add_c(@idx, new_autofloat.idx, -1 * Math.sin(@value))

    new_autofloat
  end

  def sin
    new_value = Math.sin(@value)
    new_autofloat = AutoFloat.new(new_value)

    unary_forward(new_value, new_autofloat.idx)

    add_c(@idx, new_autofloat.idx, Math.cos(@value))

    new_autofloat
  end
end

x1 = AutoFloat.new(3.0)
x2 = AutoFloat.new(5.0)
x3 = AutoFloat.new(7.0)
y = x1 + x1.cos * x2.sin * x3.log

$backward_adjoint[$global_idx] = 1.0
while $global_idx - 1 > 0
  $global_idx -= 1

  indep = $global_idx
  $backward_adjoint[indep] = 0

  $forward_dependent[indep].each do |dep|
    acc = $backward_adjoint[dep] * $c[indep][dep]
    $backward_adjoint[indep] += acc
  end
end

p $backward_adjoint