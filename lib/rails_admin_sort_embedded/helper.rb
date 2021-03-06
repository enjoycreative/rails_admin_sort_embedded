module RailsAdminSortEmbedded
  module Helper
    def rails_admin_sort_embedded(tree, opts= {})
      tree = tree.to_a.sort_by { |m| m.send(opts[:embedded_model_order_field] || "order").to_i }
      roots = tree#.select{|elem| elem.parent_id.nil?}
      id = "ns_#{rand(100_000_000..999_999_999)}"
      tree_config = {update_url: sort_embedded_path(model_name: @abstract_model),
                     embedded_field: opts[:embedded_field],
                     embedded_model_order_field: opts[:embedded_model_order_field],
                     embedded_model: @abstract_model.model.new.send(opts[:embedded_field]).new.class.to_s}.to_json
      content_tag(:ol, rails_admin_sort_embedded_builder(roots, tree), id: id, class: 'dd-list rails_admin_sort_embedded', 'data-config' => tree_config)
    end


    private

    def rails_admin_sort_embedded_builder(nodes, tree)
      nodes.map do |node|
        li_classes = 'dd-item dd3-item'

        content_tag :li, class: li_classes, :'data-id' => node.id do
          output = content_tag :div, 'drag', class: 'dd-handle dd3-handle'
          output+= content_tag :div, class: 'dd3-content clearfix' do
            content = ''.html_safe

            # toggle_fields.each do |tf|
            #   if node.respond_to?(tf) && respond_to?(:toggle_path)
            #     content += case node.enabled
            #       when nil
            #         g_link(node, '&#x2718;', 0, 'label-danger', tf) + g_link(node, '&#x2713;', 1, 'label-success', tf)
            #       when false
            #         g_link(node, '&#x2718;', 1, 'label-danger', tf)
            #       when true
            #         g_link(node, '&#x2713', 0, 'label-success', tf)
            #       else
            #         %{<span class="label">-</span>}
            #     end.html_safe
            #   end
            # end

            _title = sort_embedded_label_methods.map { |m| node.send(m) if node.respond_to?(m) }.reject(&:blank?).first
            _title = node.id if _title.blank?
            content += content_tag :span, _title

            # content += link_to @model_config.with(object: node).object_label, edit_path(@abstract_model, node.id)
            # content += extra_fields(node)
            #
            # content += content_tag(:div, action_links(node), class: 'pull-right links')

            sort_embedded_thumbnail_fields.each do |mth|
              if node.respond_to?(mth)
                img = if sort_embedded_paperclip?
                  node.send(mth).url(sort_embedded_thumbnail_size)
                elsif sort_embedded_carrierwave?
                  node.send(mth, sort_embedded_thumbnail_size)
                else
                  nil
                end
                content += image_tag(img, style: "max-height: 40px; max-width: 100px;", class: 'pull-right')
              end
            end

            sort_embedded_hint_fields.each do |hint|
              if hint.is_a?(Array)
                hint_field  = hint[0]
                if hint.size == 2
                  hint_args = hint[1]
                else
                  hint_args = hint[1..-1].to_a
                end
              else
                hint_field  = hint
                hint_args   = nil
              end

              if node.respond_to?(hint_field)
                html_code = (hint_args ? node.send(hint_field, *hint_args) : node.send(hint_field))
                content += content_tag(:div, html_code, class: 'pull-right')
              end
            end
            content
          end

          # children = tree.select{|elem| elem.parent_id == node.id}
          # output = content_tag(:div, output)
          # if children.any?
          #   output += content_tag(:ol, rails_admin_sort_embedded_builder(children, tree), class: 'dd-list')
          # end

          output
        end
      end.join.html_safe
    end


    def sort_embedded_g_link(node, fv, on, badge, meth)
      link_to(
          fv.html_safe,
          toggle_path(model_name: @abstract_model, id: node.id, method: meth, on: on.to_s),
          class: 'js-tree-toggle label ' + badge,
      )
    end

    def sort_embedded_extra_fields(node)
      "".html_safe
    end

    def sort_embedded_sort_embedded_fields
      @sort_conf.options[:fields]
    end
    def sort_embedded_fields
      @sort_conf.options[:fields]
    end

    def sort_embedded_label_methods
      @sort_conf.options[:label_methods]
    end

    # def max_depth
    #   @sort_conf.options[:max_depth] || '0'
    # end
    # def toggle_fields
    #   @sort_conf.options[:toggle_fields]
    # end
    def sort_embedded_thumbnail_fields
      @sort_conf.options[:thumbnail_fields]
    end
    def sort_embedded_hint_fields
      @sort_conf.options[:hint_fields]
    end
    def sort_embedded_paperclip?
      @sort_conf.options[:thumbnail_gem] == :paperclip
    end
    def sort_embedded_carrierwave?
      @sort_conf.options[:thumbnail_gem] == :carrierwave
    end
    def sort_embedded_thumbnail_size
      @sort_conf.options[:thumbnail_size]
    end

    def sort_embedded_action_links(model)
      content_tag :ul, class: 'inline actions' do
        menu_for :member, @abstract_model, model, true
      end
    end
  end
end
