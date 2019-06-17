# encoding: utf-8


module SeasonHelper ## use Helpers why? why not?
  def prev( season )
    ## todo: add 1964-1965 format too!!!
    if season =~ /^(\d{4})-(\d{2})$/    ## season format is  1964-65
      fst = $1.to_i - 1
      snd = (100 + $2.to_i - 1) % 100    ## note: add 100 to turn 00 => 99
      "%4d-%02d" % [fst,snd]
    elsif season =~ /^(\d{4})$/
      fst = $1.to_i - 1
      "%4d" % [fst]
    else
      puts "*** !!!! wrong season format >>#{season}<<; exit; sorry"
      exit 1
    end
  end  # method prev


  def key( basename )
    if basename =~ /^(\d{4})[\-\/](\d{4})$/      ## e.g. 2011-2012 or 2011/2012 => 2011/12
      "%4d/%02d" % [$1.to_i, $2.to_i % 100]
    elsif basename =~ /^(\d{4})[\-\/](\d{2})$/   ## e.g. 2011-12 or 2011/12  => 2011/12
      "#{$1}/#{$2}"
    elsif basename =~ /^(\d{4})$/
      $1
    else
      puts "*** !!!! wrong season format >>#{basename}<<; exit; sorry"
      exit 1
    end
  end  # method key


  def directory( season, format: nil )
    ##  todo: find better names for formats - why? why not?:
    ##    long | archive | decade(?)   =>   1980s/1988-89, 2010s/2017-18, ...
    ##    short | std(?)   =>   1988-89, 2017-18, ...

    ## convert season name to "standard" season name for directory

    ## todo/fix: move to parse / validate season (for (re)use)!!!! - why? why not?
    if season =~ /^(\d{4})[\-\/](\d{4})$/   ## e.g. 2011-2012 or 2011/2012 => 2011-12
      years = [$1.to_i, $2.to_i]
    elsif season =~ /^(\d{4})[\-\/](\d{2})$/   ## e.g. 2011-12 or 2011/12  => 2011-12
      years = [$1.to_i, $1.to_i+1]
      ## note: check that season end year is (always) season start year + 1
      if ($1.to_i+1) % 100 != $2.to_i
        puts "*** !!!! wrong season format >>#{season}<<; season end year MUST (always) equal season start year + 1; exit; sorry"
        exit 1
      end
    elsif season =~ /^(\d{4})$/
      years = [$1.to_i]
    else
      puts "*** !!!! wrong season format >>#{season}<<; exit; sorry"
      exit 1
    end


    if ['l', 'long', 'archive' ].include?( format.to_s )   ## note: allow passing in of symbol to e.g. 'long' or :long
      if years.size == 2
        "%3d0s/%4d-%02d" % [years[0] / 10, years[0], years[1] % 100]   ## e.g. 2000s/2001-02
      else  ## assume size 1 (single year season)
        "%3d0s/%4d" % [years[0] / 10, years[0]]
      end
    else  ## default 'short' format / fallback
      if years.size == 2
        "%4d-%02d" % [years[0], years[1] % 100]   ## e.g. 2001-02
      else  ## assume size 1 (single year season)
        "%4d" % years[0]
      end
    end
  end # method directory



  def start_year( season ) ## get start year
    ## convert season name to "standard" season name for directory

    ## todo/check:  just return year from first for chars - keep it simple - why? why not?
    if season =~ /^(\d{4})[\-\/](\d{4})$/   ## e.g. 2011-2010 or 2011/2011 => 2011-10
      $1
    elsif season =~ /^(\d{4})[\-\/](\d{2})$/
      $1
    elsif season =~ /^(\d{4})$/
      $1
    else
      puts "*** !!!! wrong season format >>#{season}<<; exit; sorry"
      exit 1
    end
  end

  def end_year( season ) ## get end year
    ## convert season name to "standard" season name for directory
    if season =~ /^(\d{4})[\-\/](\d{4})$/   ## e.g. 2011-2010 or 2011/2011 => 2011-10
      $2
    elsif season =~ /^(\d{4})[\-\/](\d{2})$/
      ## note: assume second year is always +1
      ##    todo/fix: add assert/check - why? why not?
      ## eg. 1999-00 => 2000 or 1899-00 => 1900
      ($1.to_i+1).to_s
    elsif season =~ /^(\d{4})$/
      $1
    else
      puts "*** !!!! wrong season format >>#{season}<<; exit; sorry"
      exit 1
    end
  end


  def pretty_print( seasons )
    ## e.g. ['2015-16', '2014-15', '2013-14', '1999-00', '1998-99', '1993-94']
    ##      => (old) 2015-16..2013-14 (3) 1999-00..1998-99 (2) 1993-94
    ##      => (new) 2016...2013 (3) 2000..1998 (2) 1993-94   - why? why not?
    ##  or
    ##      ['2014-15', '1994-95']
    ##      => 2014-15 1994-95
    ##  or
    ##      ['2017-18', '2016-17', '2015-16', '2014-15', '2013-14', '2012-13', '2011-12', '2010-11', '2009-10', '2008-09', '2006-07', '2005-06', '2004-05', '2003-04']
    ##      => 2018......2008 (10) 2006-07..2003-04 (4)

    ## first sort by latest (newest) first
    seasons = seasons.sort.reverse

    ## step 1: collect seasons in runs
    runs = []
    seasons.each do |season|

      run = runs[-1]  ## get last run (note: returns nil if empty)

      if run.nil?
        ## start new run - very first season / item
        run = []
        run << season
        runs << run
      else
        season_prev = run[-1]  ## get last season from run
        year_prev   = season_prev[0..3].to_i  ## get year

        year = season[0..3].to_i  ## get year (from season) eg. 2015-16 => 2015

        if year == year_prev-1   ## keep adding to run
          run << season
        else ## start new run
          run = []
          run << season
          runs << run
        end
      end
    end

    ## step 2: print runs into buffer (string)
    buf = ''
    runs.each do |run|
       if run.size == 1
          buf << "#{run[0]} "
       else
          ## use first and last season
          ##  try for now use .. (2)
          ##                  ... (3)
          ##                  ..... (4) etc.

          ## was: buf << run[0]
          ##  for 2017-18  print => 2018

          buf << end_year( run[0] )
          buf << ('.' * run.size)
          buf << start_year( run[-1] )
          buf << " (#{run.size}) "
       end
    end
    buf = buf.strip   # remove trainling space(s)
    buf
  end


  def pretty_print_levels( levels )   ## todo: rename to levels_up_down or levels_line or something? why? why not?
    seasons = {}  ## seasons lookup with levels
    ups   = 0
    downs = 0

    level_keys = levels.keys
    level_keys.each do |level_key|
      level = levels[level_key]
      level.seasons.each do |season|
        seasons[season] ||= []
        seasons[season] << level_key   ## todo: check if level already included? possible? why? why not?
      end
    end

    buf = ''
    last_season = nil
    last_level  = nil

    seasons.keys.sort.reverse.each do |season|
       l = seasons[season]
       if l.size > 1
         buf << "**WARN: more than one level in season #{season}: #{l.join( )}** "
       else
         lfst = l[0]
         if last_season && last_level

           ## check for season == last_season-1 or season+1 == last_season (check for proper sequence/no missing season?)
           season_exp = prev( last_season )
           if season != season_exp
              buf << " **?? #{season_exp} ??** "   ## missing season/broken run
              ## todo/fix: check/output missing more than one season in run
           end

           ## check diff
           diff = last_level - lfst.to_i
           if diff > 0
             downs += 1
             buf << "⇓"
           elsif diff < 0
             ups += 1
             buf << "⇑"
           else
             # assume diff==0; do (add) nothing
           end
         end
         buf << "#{lfst} "

         last_season = season
         last_level  = lfst.to_i   ## always use/assume int
       end
    end

   ## e.g. ⇑ (2) / ⇓ (1):  1 ⇑2 2 ⇓1 1 ⇑2 2 2 2
    buf_header = ''
    buf_header << "⇑ (#{ups})"   if ups > 0
    if downs > 0
      buf_header << " / "     if ups > 0
      buf_header << "⇓ (#{downs})"
    end
    buf_header << ": "        if ups > 0 || downs > 0


    buf_header + buf
  end

end  # module SeasonHelper


module SeasonUtils
  extend SeasonHelper
  ##  lets you use SeasonHelper as "globals" eg.
  ##     SeasonUtils.prev( season ) etc.
end # SeasonUtils
