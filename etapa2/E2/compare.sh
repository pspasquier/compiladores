files=(*)

for ((i=0; i<${#files[@]}; i++)); do
  for ((j=i+1; j<${#files[@]}; j++)); do
    if [[ "${files[i]}" != "${files[j]}" ]]; then
      if diff -q "${files[i]}" "${files[j]}" >/dev/null; then
        echo "Arquivos iguais: ${files[i]} e ${files[j]}"
      fi
    fi
  done
done
