defmodule Todo.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [Todo.System]
    opts = [strategy: :one_for_one, name: Todo.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
