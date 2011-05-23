module Jekyll
  class Page
    def last_updated
      File.mtime(File.join(@base, @dir, @name)).strftime('%Y-%m-%d')     
    end

    alias orig_to_liquid to_liquid
    def to_liquid
      h = orig_to_liquid
      h['last_updated'] = last_updated
      h
    end
  end
  
  class Post
    def last_updated
      File.mtime(File.join(@base, @name)).strftime('%Y-%m-%d')     
    end

    alias orig_to_liquid to_liquid
    def to_liquid
      h = orig_to_liquid
      h['last_updated'] = last_updated
      h
    end
  end
end
