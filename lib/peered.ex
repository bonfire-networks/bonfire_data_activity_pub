defmodule Bonfire.Data.ActivityPub.Peered do
  @moduledoc "Federated actors or objects"
  use Pointers.Mixin,
    otp_app: :bonfire_data_activity_pub,
    source: "bonfire_data_activity_pub_peered"

  alias Bonfire.Data.ActivityPub.Peer
  alias Bonfire.Data.ActivityPub.Peered

  alias Ecto.Changeset

  mixin_schema do
    belongs_to(:peer, Peer)
    field(:canonical_uri, :string)
  end

  @cast [:id, :peer_id, :canonical_uri]
  @required [:peer_id]

  def changeset(peered \\ %Peered{}, params, _opts \\ []) do
    peered
    |> Changeset.cast(params, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.assoc_constraint(:peer)
  end
end

defmodule Bonfire.Data.ActivityPub.Peered.Migration do
  @moduledoc false
  import Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.ActivityPub.Peered

  @peered_table Peered.__schema__(:source)

  # create_peered_table/{0,1}

  defp make_peered_table(exprs) do
    quote do
      require Pointers.Migration

      Pointers.Migration.create_mixin_table Bonfire.Data.ActivityPub.Peered do
        add(:peer_id, strong_pointer(Bonfire.Data.ActivityPub.Peer), null: false)

        Ecto.Migration.add(:canonical_uri, :text, null: true)
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_peered_table(), do: make_peered_table([])
  defmacro create_peered_table(do: {_, _, body}), do: make_peered_table(body)

  # drop_peered_table/0

  def drop_peered_table(), do: drop_mixin_table(Peered)

  # create_peered_peer_index/{0, 1}

  defp make_peered_peer_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@peered_table), [:peer_id], unquote(opts))
      )
    end
  end

  defmacro create_peered_peer_index(opts \\ [])
  defmacro create_peered_peer_index(opts), do: make_peered_peer_index(opts)

  def drop_peered_peer_index(opts \\ []) do
    drop_if_exists(index(@peered_table, [:peer_id], opts))
  end

  # migrate_peered/{0,1}

  defp ma(:up) do
    quote do
      unquote(make_peered_table([]))
      unquote(make_peered_peer_index([]))
    end
  end

  defp ma(:down) do
    quote do
      Bonfire.Data.ActivityPub.Peered.Migration.drop_peered_peer_index()
      Bonfire.Data.ActivityPub.Peered.Migration.drop_peered_table()
    end
  end

  defmacro migrate_peered() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(ma(:up)),
        else: unquote(ma(:down))
    end
  end

  defmacro migrate_peered(dir), do: ma(dir)
end
