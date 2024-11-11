defmodule Todo.Cache do
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    IO.puts("Starting to-do cache")
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def server_process(list_name) do
    existing_process(list_name) || new_process(list_name)
  end

  defp existing_process(list_name) do
    Todo.Server.whereis(list_name)
  end

  defp new_process(list_name) do
    case DynamicSupervisor.start_child(__MODULE__, {Todo.Server, list_name}) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end
end
