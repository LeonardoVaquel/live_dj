defmodule LiveDj.Organizer.Video do

  alias LiveDj.Organizer.Video

  @derive Jason.Encoder

  defstruct channel_title: "", description: "", img_height: "", img_url: "", img_width: "", is_queued: false, title: "", video_id: "", previous: "", next: ""

  def update(video, props) do
    Map.merge(video, props)
  end

  def from_jsonb(jsonb_video) do
    %Video{
      channel_title: jsonb_video["channel_title"],
      description: jsonb_video["description"],
      img_height: jsonb_video["img_height"],
      img_url: jsonb_video["img_url"],
      img_width: jsonb_video["img_width"],
      is_queued: jsonb_video["is_queued"],
      next: jsonb_video["next"],
      previous: jsonb_video["previous"],
      title: jsonb_video["title"],
      video_id: jsonb_video["video_id"]
    }
  end

  def from_tubex_video(tubex_video) do
    %Video{
      channel_title: tubex_video.channel_title,
      img_url: tubex_video.thumbnails["default"]["url"],
      img_height: tubex_video.thumbnails["default"]["height"],
      img_width: tubex_video.thumbnails["default"]["width"],
      is_queued: false,
      description: tubex_video.description,
      title: tubex_video.title,
      video_id: tubex_video.video_id,
      previous: "",
      next: "",
    }
  end
end
