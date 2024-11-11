defmodule Todo.DatabaseWorker do
  use GenServer

  def start_link(db_folder) do
    GenServer.start_link(__MODULE__, db_folder)
  end

  def store(pid, key, data) do
    GenServer.call(pid, {:store, key, data})
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  def init(db_folder) do
    IO.puts("Starting to-do database worker")
    File.mkdir_p!(db_folder)

    {:ok, db_folder}
  end

  def handle_call({:store, key, data}, db_folder) do
    db_folder
    |> file_name(key)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, db_folder}
  end

  def handle_call({:get, key}, _, db_folder) do
    data =
      case File.read(file_name(db_folder, key)) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        {:error, :enoent} -> nil
      end

    {:reply, data, db_folder}
  end

  defp file_name(db_folder, key) do
    Path.join(db_folder, to_string(key))
  end
end
