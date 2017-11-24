defmodule UeberauthNopass.Store do
  use GenServer

  def start_link(_param) do
    GenServer.start(__MODULE__, [], name: __MODULE__)
  end

  def new(id, email) do
    :ets.insert(:nopass, {id, email, false})
  end

  def check(id) do
    case :ets.lookup(:nopass, id) do
      [{_, _, false}] -> :not_authorized
      [{_, _, true}] -> :authorized
      _ -> :error
    end
  end

  def get_email(id) do
    case :ets.lookup(:nopass, id) do
      [{_, email, _}] -> email
      _ -> :error
    end
  end

  def complete(id) do
    case :ets.lookup(:nopass, id) do
      [{id, email, false}] ->
        :ets.update_element(:nopass, id, {3, true})
      _ ->
        :error
    end
  end

  def init(_) do
    :ets.new(:nopass, [:set, :named_table, :public, read_concurrency: true,
                    write_concurrency: true])
    {:ok, %{}}
  end
end
