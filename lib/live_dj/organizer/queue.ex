defmodule LiveDj.Organizer.Queue do

  alias LiveDj.Organizer.Video

  def get_initial_controls do
    %{is_save_enabled: false}
  end

  def mark_as_saved(queue_controls) do
    Map.merge(queue_controls, %{is_save_enabled: false})
  end

  def mark_as_unsaved(queue_controls) do
    Map.merge(queue_controls, %{is_save_enabled: true})
  end

  def is_queued(video, queue) do
    Enum.any?(queue, fn qv -> qv.video_id == video.video_id end)
  end

  def add_to_queue(queue, video) do
    case queue do
      []  -> [video]
      [v] -> [Video.update(v, %{next: video.video_id}) | [Video.update(video, %{previous: v.video_id})]]
      [v|vs] ->
        videos = Enum.drop(vs, -1)
        last_video = Video.update(List.last(vs), %{next: video.video_id})
        new_video = Video.update(video, %{previous: last_video.video_id})
        [v | videos ++ [last_video, new_video]]
    end
  end

  def remove_video_by_id(queue, video_id) do
    video = get_video_by_id(queue, video_id)
    queue = Enum.filter(queue, fn video -> video.video_id != video_id end)
    Enum.map(queue, fn v ->
      case v.next == video.video_id do
        true -> Video.update(v, %{next: video.next})
        false ->
          case v.previous == video.video_id do
            true -> Video.update(v, %{previous: video.previous})
            false -> v
          end
      end
    end)
  end

  def take_from_indexed_queue(queue, index) do
    Enum.reduce(queue, {nil,[]}, fn ({v,i}, {e, q}) ->
      case i do
        ^index -> {v, q}
        _ -> {e, q ++ [v]}
      end
    end)
  end

  def link_by_prop(queue, prop, from, to) do
    {_, queue} = Enum.reduce(queue, {"", []}, fn ({v,i}, {link_id, vs_acc}) ->
      video = case i do
        ^from                -> Video.update(v, %{prop => link_id})
        ^to                  -> Video.update(v, %{prop => link_id})
        i when (from-1) == i -> Video.update(v, %{prop => link_id})
        i when (from+1) == i -> Video.update(v, %{prop => link_id})
        i when (to-1)   == i -> Video.update(v, %{prop => link_id})
        i when (to+1)   == i -> Video.update(v, %{prop => link_id})
        _                    -> v
      end
      {video.video_id, vs_acc ++ [{video,i}]}
    end)
    queue
  end

  def link_tracks(queue, from, to) do
    queue = link_by_prop(queue, :previous, from, to)
    link_by_prop(Enum.reverse(queue), :next, from, to)
    |> Enum.reverse()
  end

  def get_video_by_id(queue, video_id) do
    Enum.find(queue, fn video -> video.video_id == video_id end)
  end

  def get_next_video(queue, current_video_id) do
    Enum.find(queue, fn video -> video.previous == current_video_id end)
  end

  def get_previous_video(queue, current_video_id) do
    Enum.find(queue, fn video -> video.next == current_video_id end)
  end
end
