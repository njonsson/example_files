defmodule ExampleFiles.UI do
  def blue(message) when is_binary(message) do
    blue([message])
  end

  def blue(ansi) when is_list(ansi) do
    [:blue] ++ ansi ++ [:default_color]
  end

  def error do
    error nil
  end

  def error(nil) do
    error ""
  end

  def error("") do
    error([""])
  end

  def error(message) when is_binary(message) do
    error([message])
  end

  def error(ansi) when is_list(ansi) do
    Mix.shell.error format(ansi)
  end

  def display_collisions(collisions) when is_map(collisions) do
    for {copied_name, copies} <- collisions do
      error
      error red("Collision detected! ") ++
            underline(copied_name)      ++
            [", corresponding to:"]
      for {_, example, _} <- copies do
        error(["• "] ++ underline(example))
      end
    end
  end

  def display_glob_pattern(glob) when is_binary(glob) do
    info(["Using glob pattern "] ++ underline(glob))
  end

  def info do
    info nil
  end

  def info(nil) do
    info ""
  end

  def info("") do
    info([""])
  end

  def info(message) when is_binary(message) do
    info([message])
  end

  def info(ansi) when is_list(ansi) do
    Mix.shell.info format(ansi)
  end

  def red(message) when is_binary(message) do
    red([message])
  end

  def red(ansi) when is_list(ansi) do
    [:red] ++ ansi ++ [:default_color]
  end

  def underline(message) when is_binary(message) do
    underline([message])
  end

  def underline(ansi) when is_list(ansi) do
    [:underline] ++ ansi ++ [:no_underline]
  end

  def yellow(message) when is_binary(message) do
    yellow([message])
  end

  def yellow(ansi) when is_list(ansi) do
    [:yellow] ++ ansi ++ [:default_color]
  end

  defp format(message) when is_binary(message) do
    format([message])
  end

  defp format(ansi) when is_list(ansi) do
    IO.ANSI.format([:reset] ++ ansi)
  end
end
