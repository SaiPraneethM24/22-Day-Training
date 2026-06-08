<script setup>
import { ref, onMounted } from 'vue'

const patients = ref([])
const searchCity = ref('')

const searchPatients = async () => {
  let url = "https://localhost:7299/api/patients/search"

  if (searchCity.value) {
    url += `?city=${encodeURIComponent(searchCity.value)}`
  }

  try {
    const response = await fetch(url)
    patients.value = await response.json()
  } catch (err) {
    console.error("Error fetching patients:", err)
    patients.value = []
  }
}
onMounted(searchPatients)
</script>

<template>
  <h1>CareBridge Patients</h1>

  <!-- Search form -->
  <form @submit.prevent="searchPatients">
    <input v-model="searchCity" type="text" placeholder="Enter city">
    <button type="submit">Search</button>
  </form>

  <h2>Showing {{ patients.length }} records</h2>

  <table border="1">
    <tr>
      <th>Patient Id</th>
      <th>Full Name</th>
      <th>City</th>
      <th>IsActive</th>
    </tr>

    <tr v-for="p in patients" :key="p.patientId">
      <td>{{ p.patientId }}</td>
      <td>{{ p.fullName }}</td>
      <td>{{ p.city }}</td>
      <td>{{ p.isActive }}</td>
    </tr>
  </table>
</template>
