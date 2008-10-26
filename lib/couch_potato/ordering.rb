module CouchPotato
  module Ordering
    def self.included(base)
      base.class_eval do
        property :position
        cattr_accessor :ordering_scope
        
        before_create :set_position
        before_create :update_positions
        before_destroy :update_lower_positions_after_destroy
        before_update :update_positions
        
        def self.set_ordering_scope(scope)
          self.ordering_scope = scope
        end
        
        def position=(new_position)
          @old_position = position
          @position = new_position
        end
      end
    end
    
    private
    
    MAX = 9999999
    
    def set_position
      self.position ||= self.class.count(scope_conditions) + 1
    end
    
    def update_positions
      @old_position = MAX if new_document?
      return unless @old_position
      if position < @old_position
        new_lower_items = find_in_positions self.position, @old_position - 1
        move new_lower_items, :down
      elsif position > @old_position
        new_higher_items = find_in_positions @old_position + 1, position
        move new_higher_items, :up
      end
    end
    
    def update_lower_positions_after_destroy
      lower_items = find_in_positions self.position + 1, MAX
      move lower_items, :up
    end
    
    def find_in_positions(from, to)
      self.class.all scope_conditions.merge(:position => from..to)
    end
    
    def scope_conditions
      if ordering_scope
        {ordering_scope => self.send(ordering_scope)}
      else
        {}
      end
    end
    
    def move(items, direction)
      items.each do |item|
        if direction == :up
          item.position -= 1
        else
          item.position += 1
        end
        self.bulk_save_queue << item
      end
    end
  end
  
  module ExternalCollectionOrderedFindExtension
    def self.included(base)
      base.class_eval do
        def items
          if @item_class.property_names.include?(:position)
            @items ||= CouchPotato::Persistence::Finder.new.find @item_class, @owner_id_attribute_name => owner_id, :position => 1..CouchPotato::Ordering::MAX
          else
            @items ||= CouchPotato::Persistence::Finder.new.find @item_class, @owner_id_attribute_name => owner_id
          end
        end
      end
    end
  end
  CouchPotato::Persistence::ExternalCollection.send :include, ExternalCollectionOrderedFindExtension
end

