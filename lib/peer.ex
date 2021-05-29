defmodule Bonfire.Data.ActivityPub.Peer do

  use Pointers.Pointable,
    otp_app: :bonfire_data_activity_pub,
    table_id: "6EERSAREH0STSWEC0NNECTW1TH",
    source: "bonfire_data_activity_pub_peer"

  alias Bonfire.Data.ActivityPub.{Peer, Peered}
  alias Ecto.Changeset

  pointable_schema do
    field :ap_base_uri, :string
    field :display_hostname, :string
    has_many :peered, Peered, foreign_key: :peer_id
  end

  @cast     [:ap_base_uri, :display_hostname]
  @required @cast

  def changeset(peer \\ %Peer{}, params, _opts \\ []) do
    peer
    |> Changeset.cast(params, @cast)
    |> Changeset.validate_required(@required)
  end

end
defmodule Bonfire.Data.ActivityPub.Peer.Migration do

  import Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.ActivityPub.Peer

  @peer_table Peer.__schema__(:source)

  # create_peer_table/{0,1}

  defp make_peer_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_pointable_table(Bonfire.Data.ActivityPub.Peer) do
        Ecto.Migration.add :ap_base_uri, :text, null: false
        Ecto.Migration.add :display_hostname, :text, null: false
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_peer_table(), do: make_peer_table([])
  defmacro create_peer_table([do: {_, _, body}]), do: make_peer_table(body)

  # drop_peer_table/0

  def drop_peer_table(), do: drop_pointable_table(Peer)

  # create_peer_ap_base_uri_index/{0,1}

  defp make_peer_ap_base_uri_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.unique_index(unquote(@peer_table), [:ap_base_uri], unquote(opts))
      )
    end
  end

  defmacro create_peer_ap_base_uri_index(opts \\ [])
  defmacro create_peer_ap_base_uri_index(opts), do: make_peer_ap_base_uri_index(opts)

  def drop_peer_ap_base_uri_index(opts \\ [])
  def drop_peer_ap_base_uri_index(opts),
    do: drop_if_exists(unique_index(@peer_table, [:ap_base_uri], opts))

  defp make_peer_display_hostname_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@peer_table), [:display_hostname], unquote(opts))
      )
    end
  end

  defmacro create_peer_display_hostname_index(opts \\ [])
  defmacro create_peer_display_hostname_index(opts), do: make_peer_display_hostname_index(opts)

  def drop_peer_display_hostname_index(opts \\ []) do
    drop_if_exists(index(@peer_table, [:display_hostname], opts))
  end

  # migrate_peer/{0,1}

  defp mp(:up) do
    quote do
      unquote(make_peer_table([]))
      unquote(make_peer_ap_base_uri_index([]))
      unquote(make_peer_display_hostname_index([]))
    end
  end
  defp mp(:down) do
    quote do
      Bonfire.Data.ActivityPub.Peer.Migration.drop_peer_display_hostname_index()
      Bonfire.Data.ActivityPub.Peer.Migration.drop_peer_ap_base_uri_index()
      Bonfire.Data.ActivityPub.Peer.Migration.drop_peer_table()
    end
  end

  defmacro migrate_peer() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mp(:up)),
        else: unquote(mp(:down))
    end
  end

  defmacro migrate_peer(dir), do: mp(dir)

end
