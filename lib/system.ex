defmodule Todo.System do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, nil)
  end

  def init(_) do
    children = [
      Todo.Metrics,
      Todo.Cache,
      Todo.Database,
      Todo.Web
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
