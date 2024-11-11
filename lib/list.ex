defmodule Todo.List do
  defstruct next_id: 1, entries: %{}

  def new, do: %Todo.List{}

  def add_entry(todo_list, entry) do
    entry = entry |> Map.put(:id, todo_list.next_id)
    new_entries = todo_list.entries |> Map.put(todo_list.next_id, entry)
    %Todo.List{todo_list | next_id: todo_list.next_id + 1, entries: new_entries}
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Map.values()
    |> Enum.filter(&(&1.date == date))
  end

  def update_entry(todo_list, entry_id, updater_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        new_entry = updater_fun.(old_entry)
        new_entries = todo_list.entries |> Map.put(entry_id, new_entry)
        %Todo.List{todo_list | entries: new_entries}
    end
  end

  def delete_entry(todo_list, entry_id) do
    %Todo.List{todo_list | entries: Map.delete(todo_list.entries, entry_id)}
  end
end
