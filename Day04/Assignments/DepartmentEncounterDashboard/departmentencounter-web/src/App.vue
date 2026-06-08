<script setup>
import { ref, onMounted } from 'vue'

const encounters = ref([])

onMounted(async () => {
  const response = await fetch('https://localhost:7042/api/analytics/department-load')
  encounters.value = await response.json()
})
</script>

<template>
  <h1>Department Encounter Overview</h1>

  <table border="1" style="width: 80%; margin: auto; text-align: center;">
    <thead>
      <tr style="background-color: #f0f0f0;">
        <th>Department Name</th>
        <th>Inpatient</th>
        <th>Outpatient</th>
        <th>ED</th>
        <th>Total</th>
      </tr>
    </thead>

    <tbody>
      <tr
        v-for="(e, index) in encounters"
        :key="index"
        >
        <td>{{ e.departmentName }}</td>
        <td>{{ e.inpatient }}</td>
        <td>{{ e.outpatient }}</td>
        <td>{{ e.ed }}</td>
        <td>{{ e.total }}</td>
      </tr>
    </tbody>
  </table>
</template>
