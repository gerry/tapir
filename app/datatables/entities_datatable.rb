class EntitiesDatatable
  delegate :params, :h, :link_to, :number_to_currency, to: :@view

  def initialize(view, entities)
    @view = view
    @entities = entities
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Entities::Base.all.count,
      iTotalDisplayRecords: data.count,
      aaData: page(data)
    }
  end

private

  def data
    data = []
    entities.map do |criteria|
      criteria.map do |entity|
      data << [
        entity.class.to_s,
        link_to(entity.name, "/entities/#{entity._id}"),
        entity.updated_at
      ]
      end
    end
  data
  end

  def entities
    # Fetch the correct entities

    entities = []
    if params[:sSearch].present?
      @entities.map.each {|x| entities << x.where( :name => /#{params[:sSearch]}/i ).order_by("#{sort_column} #{sort_direction}")}
    else
      entities = @entities #.order_by("#{sort_column} #{sort_direction}")
    end

    entities
  end

  def page(data)
    data[start..(start + per_page)]
  end

  def start
    params[:iDisplayStart].to_i #/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 100
  end

  def sort_column
    columns = %w[ type name ]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end