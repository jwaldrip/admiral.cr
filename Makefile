ci: spec examples

spec:
	@crystal spec

examples:
	@bash -c '\
    cd ./examples && \
    for f in `ls -1 ./*.cr` ; do \
      (crystal run $$f &> /dev/null && printf "\e[32m.\e[0m") || printf "\e[31mF\e[0m" ; \
    done ; \
    echo ; \
    for f in `ls -1 ./*.cr` ; do \
      crystal build -o /dev/null $$f || true ; \
    done ; \
    for f in `ls -1 ./*.cr` ; do \
      crystal run $$f &> /dev/null ; \
    done ; \
  '

.PHONY: examples spec ci
