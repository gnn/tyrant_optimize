MAIN := uo
SRCS := $(wildcard *.cpp)
OBJS := $(patsubst %.cpp,obj/%.o,$(SRCS))
INCS := $(wildcard *.h)

ifndef VERSION
VERSION = $(shell git describe --tags --abbrev=0 --dirty)
endif
ifeq ($(VERSION),)
VERSION=NO VERSION
${warning "VERSION is not set (USING NO VERSION instead), use make VERSION=vX.XX.X"}
endif

# CPPFLAGS := -Wall -Werror -std=gnu++11 -Ofast -DNDEBUG -DNQUEST -DTYRANT_OPTIMIZER_VERSION='"$(VERSION)"'
CPPFLAGS := -Wall -std=c++11 -O3 -pthreads -DNDEBUG -DNQUEST -DTYRANT_OPTIMIZER_VERSION='"$(VERSION)"'
LDFLAGS := -lboost_system -lboost_thread -lboost_filesystem -lboost_regex -lboost_chrono -lboost_timer

CPPFLAGS := $(CPPFLAGS) -I/home/stguenth/coding/local/boost_1_59_0/include
LDFLAGS := -L/home/stguenth/coding/local/boost_1_59_0/lib $(LDFLAGS)
# XML := "cards.xml" "fusion_recipes_cj2.xml" "missions.xml" "skills_set.xml"
XML := "fusion_recipes_cj2.xml" "missions.xml" "skills_set.xml"

#all: $(MAIN) debug test
all: $(MAIN)

test:
		$(MAKE) -f make/Makefile-test.${OS} all

obj/%.o: %.cpp $(INCS)
	$(CXX) $(CPPFLAGS) -o $@ -c $<

$(MAIN): $(OBJS)
	$(CXX) -o $@ $(OBJS) $(LDFLAGS)
debug:
		$(MAKE) -f make/Makefile-debug.${OS} all

xml:
	for F in $(XML); do\
	  wget -O "data/$$F" "http://mobile.tyrantonline.com/assets/$$F";\
  done;

	  for F in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19; do\
	  wget -O "data/cards_section_$$F.xml" \
		  "http://mobile.tyrantonline.com/assets/cards_section_$$F.xml";\
  done;

clean:
		$(MAKE) -f make/Makefile.${OS} clean
		$(MAKE) -f make/Makefile-debug.${OS} clean
		$(MAKE) -f make/Makefile-test.${OS} clean
		rm -f $(MAIN) obj/*.o
commit:
		-git add .
		-git commit
push: commit
		git push
release: ahk push
		git tag $(shell git describe --tags --abbrev=0 | perl -lpe 'BEGIN { sub inc { my ($$num) = @_; ++$$num } } s/(v\d+\.\d+\.)(\d+)/$$1 . (inc($$2))/eg')
		git push --tags
pull: commit
		git pull
