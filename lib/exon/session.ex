defmodule Exon.Session do

  use GenServer
  use Combine
  require Logger


  def start_link(socket) do
    GenServer.start_link(__MODULE__, socket, [])
  end

  def init(socket) do
    client = peer_infos(socket)
    Logger.debug "Handling session for peer #{inspect client} with pid #{inspect self}"
    GenServer.cast(self, {:handle, client})
    {:ok, client}
  end

###############
# GenServer API
###############

  def handle_cast({:handle, client}, state) do
    Logger.debug "Handling #{inspect client}"
    case :gen_tcp.recv(client.socket, 0 ,:infinity) do
      {:ok, "quit" <> _rst} ->
        Logger.debug("[#{inspect(self)}] #{client.host}:#{client.port} has quit")
        :gen_tcp.close(client.socket)

      {:ok, "auth " <> info} ->
        Logger.debug "Authentificating #{client.ip} on socket #{inspect client.socket}"
        GenServer.cast(self, {:parse_auth, info, client})

      {:ok, data} ->
        handler(data, client)
        GenServer.cast(self, {:handle, client})

      {:error, :closed} ->
        Logger.debug("[#{inspect(self)}] client #{client.host} unexpectedly closed the connection")

      {:error, :einval} -> 
        Logger.warn("Something fucked up with #{client.host}!")
    end

    {:noreply, state}
  end

  def handle_cast({:parse_auth, info, client}, state) do
    updated_client = case Combine.parse(info, parser) do
      [[{"username", username}, {"passwd", passwd}]] ->
        case %{identity: username, passwd: passwd} |> auth do
          {:ok, user} ->
            %{client | authed: true, username: user.username}

          {:error, msg} ->
            Logger.warn msg
            client
        end

      _ -> 
        GenServer.cast(self, {:send_pkt, Exon.Server.protocol})
        client
    end
    GenServer.cast(self, {:handle, updated_client})
    {:noreply, state}
  end

  def handle_cast({:parse_add, info, client}, state) do
    Logger.debug "Received `add` request from #{inspect client}"
    result = parse_add(info, client)
    :gen_tcp.send(client.socket, result)
    {:noreply, state}
  end

  def handle_cast({:id, id}, client=state) do
    result = Exon.Server.get_id(id)
    :gen_tcp.send(client.socket, result)
    {:noreply, state}
  end

  def handle_cast({:comment, info}, client=state) do
    result = parse_comment(info)
    :gen_tcp.send(client.socket, result)
    {:noreply, state}
  end

  def handle_cast({:send_pkt, msg}, client=state) do
    :gen_tcp.send(client.socket, msg)
    {:noreply, state}
  end

#############
# Backend API
#############

  @spec auth(map) :: {:ok, %Exon.Client{}} | {:error, String.t}
  defp auth(credentials) when is_map(credentials) do
    case Aeacus.authenticate %{identity: credentials[:identity], password: credentials[:passwd]} do
      {:ok, user}       -> 
        Logger.info "Sucessful authentication for " <> user.username
        {:ok, user}
      {:error, msg} -> 
        Logger.warn "Failed login for " <> credentials[:identity]
        Logger.info msg
        {:error, msg}
    end
  end

  @spec handler(String.t, %Exon.Client{}) :: :ok | :ok
  defp handler(line, client) do
    case sanitize_linebreaks(line) do
      "id " <> id         -> GenServer.cast(self, {:id, id})
      "add " <> info      -> GenServer.cast(self, {:parse_add, info, client})
      "comment " <> info  -> GenServer.cast(self, {:comment, info})
      ""                  -> GenServer.cast(self, {:send_pkt, ""})
      _                   -> GenServer.cast(self, {:send_pkt, Exon.Server.protocol()})
    end
  end

  @spec sanitize_linebreaks(binary) :: String.t | String.t
  defp sanitize_linebreaks(line) do
    if String.valid?(line) do
      line |> String.replace("\r", "") |> String.replace("\n", "")
    else
      ""
    end
  end

  @spec parse_add(String.t, %Exon.Client{}) :: String.t | String.t
  defp parse_add(info, client) do
    case Combine.parse(info, parser) do
      [[{"name", name}, {"comments", comments}]] ->
        Exon.Server.new_item(name, comments, client)
      _ ->
        Exon.Server.protocol
    end
  end

  @spec parse_comment(String.t) :: String.t | String.t
  defp parse_comment(info) do
    case Combine.parse(info, parser) do
      [[{"id", id}, {"comments", comments}]] ->
        Exon.Server.new_comment(String.to_integer(id), comments)
      _ ->
        Exon.Server.protocol
    end
  end

  @spec peer_infos(port) :: %Exon.Client{}
  defp peer_infos(socket) do
    {:ok, {addr, remote_port}} = :inet.peername(socket)
    ip_string = List.to_string(:inet_parse.ntoa(addr))
    host = case :inet.gethostbyaddr(addr) do
      { :ok, { :hostent, hostname, _, _, _, _ } } -> List.to_string(hostname)
      { :error, _ } -> ip_string
    end
    struct(%Exon.Client{}, %{socket: socket, ip: ip_string, host: host, port: remote_port, authed: false})
  end

  defp parser do
    sep_by1(map(
      sequence([pair_left(word, char(?=)),
        between(char(?"), word_of(~r/[\w.,!¡-‑–—@\s]/u), char(?"))
      ]),
      fn([key, value]) -> {key, value} end),
      string("::")
    )
  end
end
