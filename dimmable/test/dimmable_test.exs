defmodule DimmableTest do
  use ExUnit.Case
  doctest Dimmable

  # setup macro runs before each test
  setup do
    f = Dimmable.start
    {:ok, pid: f}
  end

  test "Start Dimmable return pid", state do
    assert nil != state[:pid]
  end

  test "Initial setting after starting is 5", state do
    p = state[:pid]
    [state, level] = Dimmable.display(p)
    assert state == "Off"
    assert level == 5
  end

  test "dail left to decrease light level has no effect when switch is off", state do
    p = state[:pid]
    [_state, level] = Dimmable.dial_left(p, 10)
    assert level == 5
  end

  test "dail left decreasing cannot go beyond 0 when switch is on" do
    f = Dimmable.start
    [state, level] = Dimmable.dial_left(f, 10)
    assert state == "Off"
    assert level == 5

    # turn of switch
    [state, _level] = Dimmable.toggle(f)
    assert state == "On"

    # dail below 0
    [_state, level] = Dimmable.dial_left(f, 10)
    assert level == 0
  end

  test "dail left decrement 3 times when switch is on" do
    f = Dimmable.start
    [state, level] = Dimmable.dial_left(f, 10)
    assert state == "Off"
    assert level == 5

    # turn of switch
    [state, _level] = Dimmable.toggle(f)
    assert state == "On"

    # dail below 0
    Dimmable.dial_left(f, 1)
    Dimmable.dial_left(f, 1)
    [_state, level] = Dimmable.dial_left(f, 1)
    assert level == 2

  end

  test "dail right increment 2 times to make up to level 7 from default" do
    f = Dimmable.start # default to ["Off", 5]

    # turn on
    Dimmable.toggle(f)

    # dail right increment by 1
    [_state, level] = Dimmable.dial_right(f, 1)
    assert level == 6

    # dail right increment by 1 again
    [_state, level] = Dimmable.dial_right(f, 1)
    assert level == 7
  end

  test "dial right, increment, cannot go beyond level 10", state do
    p = state[:pid]

    Dimmable.toggle(p)

    # dail right increment by 10 to 5
    [_state, level] = Dimmable.dial_right(p, 15)
    assert level == 10
  end

  test "switch off and switch on remember last dial position", state do
    f = state[:pid]
    [state, level] = Dimmable.toggle(f)
    assert state == "On"
    assert level == 5

    [_state, level] = Dimmable.dial_left(f, 2)
    assert level == 3

    # turn off
    [state, _level] = Dimmable.toggle(f)
    assert state == "Off"

    # change dail have no effect on level
    [_state, level] = Dimmable.dial_right(f, 10)
    assert level == 3

     # change dail have no effect on level
     [state, level] = Dimmable.toggle(f)
     assert state == "On"
     assert level == 3
  end
end
