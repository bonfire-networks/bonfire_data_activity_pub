defmodule Bonfire.Data.ActivityPub.Peered do


  use Pointers.Mixin,
    otp_app: :bonfire_data_activity_pub,
    source: "bonfire_data_activity_pub_peered"

  alias Bonfire.Data.ActivityPub.{Peer, Peered}
  alias Pointers.Changesets

  mixin_schema do
    belongs_to :peer, Peer
  end

  @defaults [
    cast: [:peer_id],
    required: [:peer_id]
  ]

  def changeset(peered \\ %Peered{}, attrs, opts \\ []) do
    Changesets.auto(peered, attrs, opts, @defaults)
  end

end
defmodule Bonfire.Data.ActivityPub.Peered.Migration do

  import Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.ActivityPub.{Peer, Peered}

  @peered_table Peered.__schema__(:source)

  # create_peered_table/{0,1}

  defp make_peered_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_mixin_table(Bonfire.Data.ActivityPub.Peered) do
        add :peer_id, strong_pointer(Bonfire.Data.ActivityPub.Peer), null: false 
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_peered_table(), do: make_peered_table([])
  defmacro create_peered_table([do: {_, _, body}]), do: make_peered_table(body)

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

  def migrate_peer(dir \\ direction())

  def migrate_peer(:up) do
    create_mixin_table(Peered) do
      add :peer_id, strong_pointer(Peer)
    end
    create_if_not_exists(unique_index(@peered_table, :peer_id))
  end

  def migrate_peer(:down) do
    drop_if_exists(unique_index(@peered_table, :peer_id))
    drop_mixin_table(Peered)
  end

end
