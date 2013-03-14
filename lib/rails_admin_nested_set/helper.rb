module RailsAdminNestedSet
  module Helper
    def nested_set_ui_class_of(tree)
      case
        when defined?(ActiveRecord) && tree.is_a?(ActiveRecord::Relation) then tree.name.to_s.underscore.downcase
        when tree.empty? then nil
        else tree.first.class.to_s.underscore.downcase
      end
    end

    def nested_set_ui(tree, opts= {})
      tree = tree.to_a.sort_by { |m| m.lft }
      roots = tree.select{|elem| elem.parent_id.nil?}
      id = "ns_#{rand(100_000_000..999_999_999)}"
      content_tag(:div, nested_set_ui_builder(roots, tree), id: id, class: 'nested_set_ui')
    end


    def nested_set_ui_builder(nodes, tree)
      nodes.each do |node|
        li_classes = 'dd-item dd3-item'

        content_tag :li, class: li_classes, :'data-id' => node.id do

          output = content_tag :div, 'drag', class: 'dd-handle dd3-handle'
          output+= content_tag :div, class: 'dd3-content' do
            content = link_to @model_config.with(object: node).object_label, edit_path(@abstract_model, node.id)
            content + content_tag(:div, action_links(node), class: 'pull-right links')
          end

          children = tree.select{|elem| elem.parent_id == node.id}
          if children.any?
            output += content_tag :ol, nested_set_ui_builder(children, tree), class: 'dd-list'
          end

          output
        end
      end.join.html_safe
    end

    def action_links(model)
      content_tag :ul, class: 'inline actions' do
        menu_for :member, @abstract_model, model, true
      end
    end
  end
end