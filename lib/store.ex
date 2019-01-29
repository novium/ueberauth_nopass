defmodule UeberauthNopass.Store do
@moduledoc """
Stores pending authentication requests
| CODE | SESSION_ID | STATUS | EMAIL |
Code should be emailed to user
Session ID uniquely identifies user
Used can be either: :waiting, :authorized, :done
Delete when used!
"""
  use GenServer

  def start_link(_param) do
    GenServer.start(__MODULE__, [], name: __MODULE__)
  end

  def new(id, code, session, email) do
    :ets.insert(:nopass, {id, code, session, :waiting, email})
  end

  # Checks code status
  def check_code(id, code) do
    case hd(:ets.lookup(:nopass, id)) do
      {^id, ^code, _, status, _} -> status
      _ -> :not_found
    end
  end

  # Checks if session is authorized
  def check_session(id, sessionid) do
    case hd(:ets.lookup(:nopass, id)) do
      {^id, _, ^sessionid, status, _} -> status
      _ -> :not_found
    end
  end

  # Get email from code
  def get_email(id) do
    case hd(:ets.lookup(:nopass, id)) do
      {^id, _, _, _, email} -> email
      _ -> :error
    end
  end

  # Sets a code to authorized.
  def authenticate_code(id, code) do
    case hd(:ets.lookup(:nopass, id)) do
      {^id, ^code, sessionid, :waiting, email} ->
        :ets.delete(:nopass, id)
        :ets.insert(:nopass, {id, code, sessionid, :authorized, email})
      _ ->
        :error
    end
  end

  # Set session to used
  def authenticate_session(id, sessionid) do
    case hd(:ets.lookup(:nopass, id)) do
      {^id, code, ^sessionid, :authorized, email} ->
        :ets.delete(:nopass, id)
        :ets.insert(:nopass, {id, code, sessionid, :done, email})
      _ ->
        :error
    end
  end

  def init(_) do
    :ets.new(:nopass, [:set, :named_table, :public, read_concurrency: true,
                       write_concurrency: true])
    :ets.insert(:nopass, {"123", "abc123", "123abc", :waiting, "elmoo32@gmail.com"}) #TODO: Remove!
    {:ok, %{}}
  end
end
