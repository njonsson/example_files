defmodule ExampleFiles.Application do
  @moduledoc false

  use Application

  def start(_type, arguments) do
    ExampleFiles.UI.start_link arguments, name: ExampleFiles.UI
  end
end
