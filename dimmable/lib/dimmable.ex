defmodule Dimmable do
  # spawn a separate process
  def start do
    spawn(fn -> loop("Off", 5) end)
  end

  # private loop inside object
  defp loop(current_state, current_value) do
    [new_state, new_value] = receive do
      {:value, client_id} ->
        send(client_id, {:response, [current_state, current_value]})
          [current_state, current_value]

      {:dial_left, value} -> [current_state, cond do
        current_state == "On" -> current_value - value
        current_state == "Off" -> current_value
      end]

      {:dial_right, value} -> [current_state, cond do
        current_state == "On" -> current_value + value
        current_state == "Off" -> current_value
      end]

      {:toggle} -> [cond do
        current_state == "On" -> "Off"
        current_state == "Off" -> "On"
      end, current_value]

      {:display} -> [current_state, current_value]

      invalid_request -> IO.puts("Invalid request #{inspect invalid_request}")
        [current_state, current_value]
    end

    # prevent value going over upper and lower bound`
    [new_state, new_value] = cond do
      new_value < 0 -> [new_state, 0]
      new_value > 10 -> [new_state, 10]
      new_value >= 0 && new_value <= 10 -> [new_state, new_value]
    end

    loop(new_state, new_value)
  end

  def value(server_id) do
    send(server_id, {:value, self()})
    receive do
      {:response, value} -> value
    end
  end

  def dial_left(server_id, value) do
    send(server_id, {:dial_left, value})
    value(server_id)
  end

  def dial_right(server_id, value) do
    send(server_id, {:dial_right, value})
    value(server_id)
  end

  def toggle(server_id) do
    send(server_id, {:toggle})
    value(server_id)
  end

  def display(server_id) do
    send(server_id, {:display})
    value(server_id)
  end
end
