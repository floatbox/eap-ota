class PresetsController < ApplicationController
  def index
    @presets = Preset.all
  end

  def show
    @preset = Preset.find_by_name(params[:id])
  end

  def edit
    @preset = Preset.find_by_name(params[:id])
  end

  def update
    @preset = Preset.find_by_name(params[:id])
    @preset.attributes = params[:preset]
    if @preset.save
      redirect_to @preset
    else
      render :edit
    end
  end

  def destroy
    @preset = Preset.find_by_name(params[:id])
    @preset.destroy
    redirect_to presets_url
  end

  # new и create - не делаю пока
end
