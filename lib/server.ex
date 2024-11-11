defmodule Todo.Server do
  use GenServer, restart: :temporary

  @module __MODULE__
  @expiry_idle_timeout :timer.seconds(10)

  def start_link(name) do
    GenServer.start_link(@module, name, name: global_name(name))
  end

  @impl GenServer
  def init(name) do
    IO.puts("Starting to-do list server")
    {:ok, {name, nil}, {:continue, :init}}
  end

  defp global_name(name) do
    {:global, {__MODULE__, name}}
  end

  def whereis(name) do
    case :global.whereis_name({__MODULE__, name}) do
      :undefined -> nil
      pid -> pid
    end
  end

  def add_entry(pid, entry), do: GenServer.cast(pid, {:add_entry, entry})

  def update_entry(pid, entry_id, updater_func),
    do: GenServer.cast(pid, {:update_entry, entry_id, updater_func})

  def delete_entry(pid, entry_id), do: GenServer.cast(pid, {:delete_entry, entry_id})
  def get_entries(pid, date), do: GenServer.call(pid, {:get_entries, date})

  @impl GenServer
  def handle_continue(:init, {name, nil}) do
    todo_list = Todo.Database.get(name) || Todo.List.new()
    {:noreply, {name, todo_list}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_info(:timeout, {name, todo_list}) do
    IO.puts("Stopping to-do server for #{name}")
    {:stop, :normal, {name, todo_list}}
  end

  @impl GenServer
  def handle_cast({:add_entry, entry}, {name, todo_list}) do
    new_todo_list = Todo.List.add_entry(todo_list, entry)
    Todo.Database.store(name, new_todo_list)
    {:noreply, {name, new_todo_list}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_cast({:update_entry, entry_id, updater_func}, {name, todo_list}) do
    new_todo_list = Todo.List.update_entry(todo_list, entry_id, updater_func)
    {:noreply, {name, new_todo_list}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_cast({:delete_entry, entry_id}, {name, todo_list}) do
    new_todo_list = Todo.List.delete_entry(todo_list, entry_id)
    {:noreply, {name, new_todo_list}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_call({:get_entries, date}, _from, {name, todo_list}) do
    entries = Todo.List.entries(todo_list, date)
    {:reply, entries, {name, todo_list}, @expiry_idle_timeout}
  end
end
